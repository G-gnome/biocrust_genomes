import sys
from Bio import SeqIO
from Bio.Seq import Seq
import re

# Function to extract species from the description
def extract_species(description):
    match = re.match(r'\S+\s+(\S+\s+\S+)\s+', description)
    return match.group(1) if match else None

# Function to read sequences from a file and create a dictionary with species names as keys
def create_species_dict(infile):
    handle = open(infile, "r")
    record_dict = SeqIO.to_dict(SeqIO.parse(handle, "fasta"))
    handle.close()
    return {extract_species(record.description): record for record in record_dict.values()}

def print_help():
    print("Usage: python script.py ITS_file LSU_file merge_report_file")
    sys.exit(0)

def calculate_sequence_identity(seq1, seq2):
    return sum(a == b for a, b in zip(seq1, seq2)) / max(len(seq1), len(seq2))

def main():
    # Get command-line arguments
    if len(sys.argv) == 2 and sys.argv[1] == "--help":
        print_help()

    if len(sys.argv) != 4:
        print("Error: Invalid number of arguments.")
        print_help()

    infile_ITS = sys.argv[1]
    infile_LSU = sys.argv[2]
    report_filename = sys.argv[3]
    output_filename = "merged_sequences.fasta"

    # Read ITS sequences
    record_dict_ITS = SeqIO.to_dict(SeqIO.parse(infile_ITS, "fasta"))
    species_dict_ITS = create_species_dict(infile_ITS)

    # Read LSU sequences
    record_dict_LSU = SeqIO.to_dict(SeqIO.parse(infile_LSU, "fasta"))
    species_dict_LSU = create_species_dict(infile_LSU)

    # Combine sequences based on species name
    combined_dict = {}
    merge_report = {}

    for species in set(species_dict_ITS.keys()).union(species_dict_LSU.keys()):
        if species in species_dict_ITS and species in species_dict_LSU:
            its_sequence = str(species_dict_ITS[species].seq)
            lsu_sequence = str(species_dict_LSU[species].seq)
            combined_sequence = its_sequence + lsu_sequence

            # Check for 100% sequence identity within merged sequences
            if species in combined_dict:
                existing_sequence = str(combined_dict[species].seq)
                identity = calculate_sequence_identity(combined_sequence, existing_sequence)
                if identity == 1.0:
                    merge_report[species] = "Error: 100% sequence identity in merged sequences"

            # Create a combined record
            combined_record = SeqIO.SeqRecord(Seq(combined_sequence), id=species, description=f"Combined {species} ITS and LSU")

            # Add to the combined dictionary
            combined_dict[species] = combined_record

            # Update merge report with sequence lengths
            its_length = len(its_sequence)
            lsu_length = len(lsu_sequence)
            combined_length = len(combined_sequence)

            merge_report[species] = {
                'ITS_length': its_length,
                'LSU_length': lsu_length,
                'Combined_length': combined_length,
            }
        else:
            if species in species_dict_ITS and species not in species_dict_LSU:
                merge_report[species] = "LSU sequence not found"
            elif species in species_dict_LSU and species not in species_dict_ITS:
                merge_report[species] = "ITS sequence not found"

    # Write merged sequences to a file
    SeqIO.write(combined_dict.values(), output_filename, "fasta")

    # Write report to a file
    with open(report_filename, "w") as report_file:
        report_file.write("Merge Report:\n")
        for species, details in merge_report.items():
            if isinstance(details, str):  # If merge unsuccessful or 100% identity
                report_file.write(f"{species}: {details}\n")
            else:  # If merge successful

if __name__ == "__main__"
    main()

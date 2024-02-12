from Bio import SeqIO
import sys
import re

# Function to extract species from the description
def extract_species(description):
    match = re.match(r'\S+\s+(\S+\s+\S+)\s+', description)
    return match.group(1) if match else None

def rename_headers(input_file, output_file):
    records = []
    with open(input_file, "r") as infile:
        for record in SeqIO.parse(infile, "fasta"):
            species_name = extract_species(record.description)
            if species_name:
                record.id = species_name
                record.name = ""
                record.description = ""
                record.dbxrefs = []
                records.append(record)

    with open(output_file, "w") as outfile:
        SeqIO.write(records, outfile, "fasta")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python rename.py input.fasta output.fasta")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    rename_headers(input_file, output_file)
    print(f"FASTA headers renamed. Output saved to {output_file}")

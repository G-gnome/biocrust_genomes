from Bio import SeqIO
import sys
import re

# Function to extract species from the description and replace space with underscore
def extract_species(description, replacement_header=None):
    print("Description:", description)  # Debug print
    match = re.match(r'\S+\s+(\S+)\s+(\S+)\s+', description)
    if match:
        genus = match.group(1)
        species = match.group(2)
        return f"{genus}_{species}"
    else:
        if replacement_header:
            return replacement_header.replace(" ", "_")
        else:
            match = re.match(r'>(\S+)', description)
            if match:
                return match.group(1).replace(" ", "_")
    return None

def rename_headers(input_file, output_file, replacement_header=None):
    records = []
    error_log = []

    with open(input_file, "r") as infile:
        for record in SeqIO.parse(infile, "fasta"):
            if record.description.strip():  # Check if description is not empty
                species_name = extract_species(record.description, replacement_header)
                if species_name:
                    record.id = species_name
                    record.name = ""
                    record.description = ""
                    record.dbxrefs = []
                    records.append(record)
                else:
                    error_log.append(f"Error processing header: {record.description}. Reason: Header format not recognized. Record description: {record.description}")
            else:
                error_log.append(f"Error processing header: {record.id}. Reason: Description is empty.")

    with open(output_file, "w") as outfile:
        SeqIO.write(records, outfile, "fasta")

    if error_log:
        with open("header_errors.log", "w") as log_file:
            for error in error_log:
                log_file.write(error + "\n")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python rename.py input.fasta output.fasta [replacement_header]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    replacement_header = None
    if len(sys.argv) == 4:
        replacement_header = sys.argv[3]

    rename_headers(input_file, output_file, replacement_header)
    print(f"FASTA headers renamed. Output saved to {output_file}")

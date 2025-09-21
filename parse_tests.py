#!/usr/bin/env python3
"""
Parser for floating point test files.
Parses tests from TSV format and organizes them into separate test cases.
"""

import os
import re
import glob
from collections import defaultdict

def parse_test_line(line):
    """
    Parse a single test line.
    
    Format 1: h/s type operand1 OP operand2,result
    Format 2: h/s type operand,result
    
    Returns: (precision, type, operation, operands, result)
    """
    line = line.strip()
    if not line:
        return None
    
    # Split by comma to separate input from result
    parts = line.split(',', 1)
    if len(parts) != 2:
        return None
    
    input_part = parts[0].strip()
    result = parts[1].strip()
    
    # Parse input part
    tokens = input_part.split()
    if len(tokens) < 3:
        return None
    
    precision = tokens[0]  # 'h' or 's'
    test_type = tokens[1]  # '0', '1', etc.
    
    if len(tokens) == 3:
        # Format 2: h/s type operand,result (print operation)
        operand = tokens[2]
        return (precision, test_type, 'print', [operand], result)
    elif len(tokens) == 5:
        # Format 1: h/s type operand1 OP operand2,result
        operand1 = tokens[2]
        operation = tokens[3]
        operand2 = tokens[4]
        return (precision, test_type, operation, [operand1, operand2], result)
    else:
        return None

def create_test_files(test_data, output_dir):
    """
    Create individual test files in the required format.
    Each test gets its own directory: operation_type_index
    """
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Keep track of test indices for each operation_type combination
    test_indices = defaultdict(int)
    
    # Operation name mapping
    operation_names = {
        '+': 'plus',
        '-': 'sub', 
        '*': 'mult',
        '/': 'div',
        'print': 'print'
    }
    
    # Create individual test files
    for precision, test_type, operation, operands, result in test_data:
        # Map operation symbol to full name
        operation_name = operation_names.get(operation, operation)
        
        # Generate unique test directory name
        base_key = f"{operation_name}_{test_type}"
        test_indices[base_key] += 1
        test_dir_name = f"{base_key}_{test_indices[base_key]}"
        test_dir = os.path.join(output_dir, test_dir_name)
        
        os.makedirs(test_dir, exist_ok=True)
        
        # Create in.txt and out.txt files
        in_file = os.path.join(test_dir, "in.txt")
        out_file = os.path.join(test_dir, "out.txt")
        
        with open(in_file, 'w') as f_in:
            if len(operands) == 1:
                # Print operation: precision type operand
                f_in.write(f"{precision} {test_type} {operands[0]}\n")
            else:
                # Binary operation: precision type operation operand1 operand2
                f_in.write(f"{precision} {test_type} {operation} {operands[0]} {operands[1]}\n")
        
        with open(out_file, 'w') as f_out:
            f_out.write(f"{result}\n")

def main():
    input_dir = "."  # Current directory where the script is located
    output_dir = "tests/itmo"
    
    # Find all TSV files that match the pattern
    test_files = glob.glob("itmo_tests/true_gen_float_*.tsv")
    
    if not test_files:
        print("No test files found matching pattern 'true_gen_float_*.tsv'")
        return
    
    print(f"Found {len(test_files)} test files: {test_files}")
    
    all_test_data = []
    total_line_count = 0
    total_parsed_count = 0
    
    for input_file in test_files:
        print(f"\nParsing {input_file}...")
        
        line_count = 0
        parsed_count = 0
        
        with open(input_file, 'r') as f:
            for line in f:
                line_count += 1
                total_line_count += 1
                parsed_test = parse_test_line(line)
                if parsed_test:
                    all_test_data.append(parsed_test)
                    parsed_count += 1
                    total_parsed_count += 1
                
                if line_count % 10000 == 0:
                    print(f"  Processed {line_count} lines, parsed {parsed_count} tests...")
        
        print(f"  File completed: {line_count} lines processed, {parsed_count} tests parsed")
    
    print(f"\nTotal across all files:")
    print(f"  Lines processed: {total_line_count}")
    print(f"  Tests parsed: {total_parsed_count}")
    
    print(f"\nCreating individual test directories in {output_dir}...")
    create_test_files(all_test_data, output_dir)
    
    print(f"Created {total_parsed_count} individual test directories!")
    print("Done!")

if __name__ == "__main__":
    main()

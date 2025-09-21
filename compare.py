#!/usr/bin/env python3
"""
Output comparator for test system.
Compares only the first number from actual output with expected output.

Usage: python3 compare.py <expected_file> <actual_output>
Returns: 0 if outputs match, 1 if they don't match

Note: Program outputs two numbers (e.g., "0x1.23cp+3 0x488F"), 
but only the first one is compared with expected result.
"""

import sys


def compare_outputs(expected_file, actual_output):
    """
    Compare expected output from file with first number from actual output.
    
    Args:
        expected_file (str): Path to file containing expected output
        actual_output (str): Actual output to compare (only first number is used)
    
    Returns:
        bool: True if outputs match, False otherwise
    """
    try:
        # Read expected output from file
        with open(expected_file, 'r') as f:
            expected_output = f.read().strip()
        
        # Split actual output by whitespace and take the first token (first number)
        actual_tokens = actual_output.strip().split()
        
        if not actual_tokens:
            print(f"Warning: No output tokens found in actual output: '{actual_output.strip()}'", file=sys.stderr)
            return False
        
        first_number = actual_tokens[0]
        
        # Compare expected output with first number from actual output
        return expected_output == first_number
        
    except FileNotFoundError:
        print(f"Error: Expected output file '{expected_file}' not found", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error reading expected output file: {e}", file=sys.stderr)
        return False


def main():
    """Main function for command line usage."""
    if len(sys.argv) != 3:
        sys.exit(2)
    
    expected_file = sys.argv[1]
    actual_output = sys.argv[2]
    
    if compare_outputs(expected_file, actual_output):
        sys.exit(0)  # Success - outputs match
    else:
        sys.exit(1)  # Failure - outputs don't match


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Verification script for RISC-V processor pipeline.
Uses the embedded assembler to verify program.txt and check simulation outputs.
"""

import sys
import os
from pathlib import Path

# Add riscv_assembler to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'riscv_assembler'))

from convert import AssemblyConverter as AC

def generate_program():
    """Generate program.txt from factorial.s using the assembler."""
    print("=" * 60)
    print("STEP 1: Generating program.txt from factorial.s")
    print("=" * 60)
    
    # Use the assembler to convert factorial.s to binary
    converter = AC(output_mode='f', nibble_mode=False, hex_mode=False)
    asm_path = os.path.join(os.path.dirname(__file__), 'riscv_assembler', 'factorial.s')
    program_path = os.path.join(os.path.dirname(__file__), 'program.txt')
    
    try:
        converter(asm_path, program_path)
        print(f"✓ Generated program.txt ({program_path})")
        
        # Count instructions
        with open(program_path, 'r') as f:
            num_instrs = len([l for l in f.readlines() if l.strip()])
        print(f"✓ Program contains {num_instrs} instructions")
        
        return True
    except Exception as e:
        print(f"✗ Error generating program: {e}")
        return False

def verify_program_format():
    """Verify that program.txt has correct format (32-bit binary per line)."""
    print("\n" + "=" * 60)
    print("STEP 2: Verifying program.txt format")
    print("=" * 60)
    
    program_path = os.path.join(os.path.dirname(__file__), 'program.txt')
    
    try:
        with open(program_path, 'r') as f:
            lines = [l.strip() for l in f.readlines() if l.strip()]
        
        all_valid = True
        for i, line in enumerate(lines):
            if len(line) != 32:
                print(f"✗ Line {i}: Invalid length {len(line)} (expected 32)")
                all_valid = False
            elif not all(c in '01' for c in line):
                print(f"✗ Line {i}: Invalid characters (expected only 0s and 1s)")
                all_valid = False
        
        if all_valid:
            print(f"✓ All {len(lines)} instructions have valid 32-bit binary format")
            return True
        return False
    except Exception as e:
        print(f"✗ Error verifying program: {e}")
        return False

def verify_output_files():
    """Verify that register_file.txt and memory.txt exist and have correct format."""
    print("\n" + "=" * 60)
    print("STEP 3: Verifying output files")
    print("=" * 60)
    
    reg_file_path = os.path.join(os.path.dirname(__file__), 'register_file.txt')
    mem_file_path = os.path.join(os.path.dirname(__file__), 'memory.txt')
    
    reg_valid = False
    mem_valid = False
    
    # Check register_file.txt
    if os.path.exists(reg_file_path):
        try:
            with open(reg_file_path, 'r') as f:
                lines = [l.strip() for l in f.readlines() if l.strip()]
            
            if len(lines) == 32:
                # Check format of each line
                all_binary = all(len(l) == 32 and all(c in '01' for c in l) for l in lines)
                if all_binary:
                    print(f"✓ register_file.txt: Valid (32 lines of 32-bit binary)")
                    reg_valid = True
                    
                    # Extract important registers
                    x10_val = int(lines[10], 2)  # a0 register
                    x11_val = int(lines[11], 2)  # a1 register
                    
                    print(f"  - x10 (a0): {x10_val} (binary: {lines[10]})")
                    print(f"  - x11 (a1): {x11_val} (binary: {lines[11]})")
                    
                    if x10_val == 120:
                        print(f"  ✓ x10 contains factorial(5) = 120 ✓✓✓")
                    else:
                        print(f"  ✗ x10 expected 120, got {x10_val}")
                else:
                    print(f"✗ register_file.txt: Invalid binary format")
            else:
                print(f"✗ register_file.txt: Expected 32 lines, got {len(lines)}")
        except Exception as e:
            print(f"✗ register_file.txt: Error reading - {e}")
    else:
        print(f"✗ register_file.txt: File not found")
    
    # Check memory.txt
    if os.path.exists(mem_file_path):
        try:
            with open(mem_file_path, 'r') as f:
                lines = [l.strip() for l in f.readlines() if l.strip()]
            
            if len(lines) == 8192:
                # Check first few lines format
                all_binary = all(len(l) == 32 and all(c in '01' for c in l) for l in lines[:min(10, len(lines))])
                if all_binary:
                    print(f"✓ memory.txt: Valid (8192 lines of 32-bit binary)")
                    mem_valid = True
                else:
                    print(f"✗ memory.txt: Invalid binary format")
            else:
                print(f"✗ memory.txt: Expected 8192 lines, got {len(lines)}")
        except Exception as e:
            print(f"✗ memory.txt: Error reading - {e}")
    else:
        print(f"✗ memory.txt: File not found")
    
    return reg_valid and mem_valid

def main():
    """Run all verification steps."""
    print("\n" + "=" * 60)
    print("RISC-V Processor Verification Script")
    print("=" * 60)
    
    # Step 1: Generate program.txt
    if not generate_program():
        print("\n✗ Failed to generate program.txt")
        return 1
    
    # Step 2: Verify program format
    if not verify_program_format():
        print("\n✗ Program format verification failed")
        return 1
    
    # Step 3: Verify output files (run after simulation)
    if verify_output_files():
        print("\n" + "=" * 60)
        print("✓ ALL VERIFICATION CHECKS PASSED")
        print("=" * 60)
        return 0
    else:
        print("\n" + "=" * 60)
        print("⚠ Output files missing or invalid - run simulation first")
        print("=" * 60)
        return 1

if __name__ == '__main__':
    sys.exit(main())

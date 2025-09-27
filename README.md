# ChaCha20-Poly1305 Formal Verification Project

This project contains formal verification implementations and proofs for the ChaCha20 stream cipher and Poly1305 message authentication code, focusing on two major implementations:

- OpenSSL implementation verification
- OpenHITLS implementation verification

## Project Structure

```
.
├── openhitls/           # OpenHITLS implementation verification
│   ├── chacha20/        # ChaCha20 verification files
│   │   ├── *.cry       # Cryptol specifications
│   │   ├── *.c         # C implementation
│   │   ├── *.bc        # LLVM bitcode files
│   │   └── *.saw      # SAW verification scripts
│   └── poly1305/       # Poly1305 verification files
│       ├── *.cry       # Cryptol specifications
│       ├── *.c         # C implementation
│       ├── *.bc        # LLVM bitcode files
│       └── *.saw      # SAW verification scripts
│
└── openssl/            # OpenSSL implementation verification
    ├── chacha20/       # ChaCha20 verification files
    │   ├── *.cry       # Cryptol specifications
    │   ├── *.c         # C implementation
    │   ├── *.bc        # LLVM bitcode files
    │   └── *.saw      # SAW verification scripts
    └── poly1305/       # Poly1305 verification files
        ├── *.cry       # Cryptol specifications
        ├── *.c         # C implementation
        ├── *.bc        # LLVM bitcode files
        └── *.saw      # SAW verification scripts
```

## Overview

This project focuses on the formal verification of two critical cryptographic primitives:

1. **ChaCha20**: A stream cipher designed by Daniel J. Bernstein
2. **Poly1305**: A message authentication code also designed by Daniel J. Bernstein

The verification is performed on two different implementations:

- **OpenSSL**: The widely-used cryptographic library
- **OpenHITLS**: A high-performance implementation

## Tools Used

- **Cryptol**: A domain-specific language for cryptographic algorithms
- **SAW (Software Analysis Workbench)**: For formal verification
- **LLVM**: For intermediate representation of C code

## File Types

- `.cry` files: Cryptol specifications
- `.c` files: C implementation source code
- `.bc` files: LLVM bitcode files
- `.saw` files: SAW verification scripts

## Verification Approach

The verification process includes:

1. Specification of the algorithms in Cryptol
2. Implementation in C
3. Generation of LLVM bitcode
4. Formal verification using SAW
5. Property checking and equivalence proofs

## Requirements

To work with this project, you need:

- Cryptol
- SAW
- LLVM toolchain
- C compiler

## Getting Started

1. Install the required tools
2. Clone this repository
3. Navigate to either the OpenSSL or OpenHITLS directory
4. Run the verification scripts using SAW

## Documentation

Each implementation directory contains its own README with specific details:

- See `openssl/README.md` for OpenSSL verification details
- See `openhitls/README.md` for OpenHITLS verification details
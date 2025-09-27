# Formal Verification of ChaCha20-Poly1305 in openHiTLS
This is the source code repo for our project, which conducts the equvalence verfication of ChaCha20：
1) described in the standard (RFC 8439), and
2) implemented in the openHiTLS (v3.0.10).

This instruction describes the organization of the source code and how to use it.

## Software Requirements
- To run the RFC and openHiTLS Cryptol formal model of TLS 1.3 state machine you need [cryptol 3.1.0+](https://cryptol.net/).
- To verify equivalence between the openHiTLS formal model and the C code implementations, you need [SAW](https://saw.galois.com/).

## File Organization
**Source code files**:

- ChaCha20 Model, in the directory ``chacha20/``
  - ``chacha_combined.c``  : Defined the source code of ChaCha20 algorithm in openHiTLS
  - ``chacha_combined.bc`` : Compiled bytecode from openHiTLS ChaCha20 algorithm source code
  - ``chacha_openHiTLS.cry`` :  Defined the ChaCha20 Cryptol model based on OpneSSL source code
  - ``chacha_rfc.cry`` : Defined the ChaCha20 Cryptol model based on RFC standard document 
  - ``chacha.saw``: The script for verifying the equvalence between openHiTLS Cryptol models and ChaCha20 C code implementations
  - ``chacha_property.cry``: Proved the ChaCha20 equvalence and some security properties between the Cryptol model based on openHiTLS and the Cryptol model based on standard documentation

## The Execution of RFC Model Alone
You can use the following commands to run the RFC Cryptol model once in the console for revision and testing.

```
PROJECTROOTDIR> cryptol
Cryptol> :l chacha_rfc.cry
encrypt: chacha_rfc> ChaCha20Encrypt k i n msg
```

## The Execution of openHiTLS Model Alone
You can use the following commands to run the openHiTLS Cryptol model once in the console for revision and testing.

```
PROJECTROOTDIR> cryptol
Cryptol> :l chacha_openhitls.cry / :l chacha_block.cry 
encrypt: Cryptol> :l chacha_property.cry 
chacha_property> CHACHA20_ENC k i n msg
```

## Compilation of LLVM Bytecode from openHiTLS Source
Before running SAW, you need to generate the LLVM `.bc` files from the openHiTLS C implementations.

First, enter the `openhitls` directory:
```
cd openhitls
```

Then compile the source files into LLVM bitcode:
```
openhitls> clang -c -std=c99 -O0 -g -DHITLS_BIG_ENDIAN -DHITLS_CRYPTO_CHACHA20 \
  -fno-discard-value-names -fno-align -emit-llvm \
  -I./config/macro_config -I./include/crypto -I./include/bsl \
  -I./crypto/include -I./crypto/chacha20/include -I./crypto/chacha20/src \
  -I./bsl/include -I./bsl/err/include -I./platform/Secure_C/include \
  -o ./crypto/chacha20/src/chacha20.bc ./crypto/chacha20/src/chacha20.c

openhitls> clang -c -std=c99 -O0 -g -DHITLS_BIG_ENDIAN -DHITLS_CRYPTO_CHACHA20 \
  -fno-discard-value-names -fno-align -emit-llvm \
  -I./config/macro_config -I./include/crypto -I./include/bsl \
  -I./crypto/include -I./crypto/chacha20/include -I./crypto/chacha20/src \
  -I./bsl/include -I./bsl/err/include -I./platform/Secure_C/include \
  -o ./crypto/chacha20/src/chacha20_blcok.bc ./crypto/chacha20/src/chacha20_block.c
```

## The Execution of SAW
You can use the following commands to run the SAWScript to verify the equvalence between openHiTLS formal models and C code implementations, and output the results to the terminal.
```
PROJECTROOTDIR> saw [filename].saw
```

## Verify the equivalence Between openHITLS and Standards
You can run the following command to verify the equivalence between the openHiTLS formal model and the standard document model, and output the result to the terminal.
```
PROJECTROOTDIR> cryptol
Cryptol> :l chacha_property.cry 
chacha_property>:set prover = yices
chacha_property>:prove ChaChaDiffCounter : [256] -> [32] -> [96] -> [96] -> [128][8] -> Bit  
```
**Note:** Before running the proof, please try to switch the SMT solver to **yices** first, since it usually performs better on this verification task.  
If `yices` fails to complete the proof, then you may try other SMT solvers (such as `z3`, `abc`, or `cvc4`).



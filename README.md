# ARKO_X86
Matrix calculator in C with algorithm in intel x86_64 assembly

Maximum matrix value is hardcoded as 254.

Operations available: +, -, *, d  (d == det)  
I/O done in C, algorithms in assembly.
Compile with make. 

Sample input.txt:
```
+		- operation
2 2		- 1st matrix's dimensions
1 3		- 1st matrix's values
4 5
2 2		- 2nd matrix's dimensions	
1 250		- 2nd matrix's values
32 4
```

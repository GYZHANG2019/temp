# Copyright 2018 VeriSilicon Inc. All Rights Reserved.
all:		
	$(CC) -o pcie_bw_test pcie_bw_test.c -lhugetlbfs 
	$(CC) -o pcie_ddr_memtest pcie_ddr_memtest.c -lhugetlbfs 

.PHONY: clean	
clean:
	rm -rf pcie_bw_test  pcie_ddr_memtest

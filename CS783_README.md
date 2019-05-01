# Readme for the analyses of CS783 (C. mycofijiensis)

### Summary of algorithms and operation system used
- Jobs were run on the Victoria University of Wellington high-performance computing cluster (raapoi) running CentOS Linux release 7.6.1810 unless otherwise specified
- slurm 18.08.4
- Singularity  2.6.0
- Trimmomatic  0.36
- quast 5.0.0
- SPAdes 3.12.0
- metaWRAP 1.0.5 (conda install)
- autometa (commit c6e398e)
- dRep v2.2.3
- barrnap 0.9

### General notes and conventions
- Note that file names including "Zamp" refer to the CS783 (C. mycofijiensis) sponge
- note that sbatch scripts are given between two lines of "" underneath the command initiating the scrpit, e.g.:
$ sbatch random_script_name.sh
""
commands
in
the
script
""
- lines starting with '$' are Unix commands
- line starting with '>' are R commands
- lines immediately following commands are output (usually truncated with ...)


## Assemblies

### PE_150 data only

#### Adapter identification and trimming
```shell
$ srun --pty -c 12 --mem=120G bash
$ bash ../adap_ID.sh Zamp_150_DSW50676-1_H7YFMCCXY_L4_1.fq.gz 
2228
This adaptor was found: >multiplexing-forward, GATCGGAAGAGCACACGTCT
1373
This adaptor was found: >PPErc/2, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
1373
This adaptor was found: >truseq-forward-contam, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
nowakvi@cadgridhigh02:~/Zamp_150$ bash ../adap_ID.sh Zamp_150_DSW50676-1_H7YFMCCXY_L4_2.fq.gz 
1382
This adaptor was found: >truseq-reverse-contam, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
1424
This adaptor was found: >solexa-forward, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
(same output as before)
$ cat adaptors.Zamp_150_DSW50676-1_H7YFMCCXY_L4_1.fq.gz.fa adaptors.Zamp_150_DSW50676-1_H7YFMCCXY_L4_2.fq.gz.fa ~/TruSeq2-PE.fa > Tru_adap_adapters_Zamp_150.fa
$ module load singularity/2.6.0
$ singularity shell trimmomatic.simg 
Singularity: Invoking an interactive shell within container...
Singularity trimmomatic.simg:~> java -jar /tools/trimmomatic/trimmomatic-0.36.jar PE -threads 12 ~/Zamp_150/Zamp_150_DSW50676-1_H7YFMCCXY_L4_1.fq.gz ~/Zamp_150/Zamp_150_DSW50676-1_H7YFMCCXY_L4_2.fq.gz -baseout ~/Zamp_150/Zamp_150_Tru_adap.fq ILLUMINACLIP:/home/nowakvi/Zamp_150/Tru_adap_adapters_Zamp_150.fa:2:30:10:4:4:/true TRAILING:9 SLIDINGWINDOW:4:15 MINLEN:36
...
ILLUMINACLIP: Using 1 prefix pairs, 10 forward/reverse sequences, 0 forward only sequences, 1 reverse only sequences
Quality encoding detected as phred33
Input Read Pairs: 35262051 Both Surviving: 33243987 (94.28%) Forward Only Surviving: 1880913 (5.33%) Reverse Only Surviving: 68308 (0.19%) Dropped: 68843 (0.20%)
TrimmomaticPE: Completed successfully
(2.49% less surviving for both)
```

#### meta-SPAdes assembly:
```shell
$ sbatch sbatch_scripts/Zamp_150_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500G
#SBATCH --partition=main
#SBATCH --time=1-12:00
#SBATCH -o /home/nowakvi/SPAdes4.out
#SBATCH -e /home/nowakvi/SPAdes4.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --meta --threads 48 --memory 500 -k 21,33,55,77,99,127 --pe1-1 ~/Zamp_150/Zamp_150_Tru_adap_1P.fq --pe1-2 ~/Zamp_150/Zamp_150_Tru_adap_2P.fq -o ~/Zamp_150_Tru_adap_meta_SPAdes
""
```
- finished without warnings
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| #contigs | 275848 |
| #contigs (>= 0 bp) | 547761 |
| #contigs (>= 1000 bp) | 125531 |
| #contigs (>= 5000 bp) | 12487 |
| #contigs (>= 10000 bp) | 4944 |
| #contigs (>= 25000 bp) | 1574 |
| #contigs (>= 50000 bp) | 593 |
| Largest contig | 1452608 |
| Total length | 525812756 |
| Total length (>= 0 bp) | 621792397 |
| Total length (>= 1000 bp) | 421185594 |
| Total length (>= 5000 bp) | 207685886 |
| Total length (>= 10000 bp) | 156570789 |
| Total length (>= 25000 bp) | 105713102 |
| Total length (>= 50000 bp) | 72216924 |
| N50 | 2987 |
| N75 | 1185 |
| L50 | 27104 |
| L75 | 100837 |
| GC (%) | 56.82 |
| Mismatches | |	
| #N's | 500 |
| #N's per 100 kbp | 0.1 |


### PE_250 data only

#### Adapter identification and trimming
```shell
$ srun --pty -c 12 --mem=120G bash
$ bash ../adap_ID.sh Zamp_250_DSW56586-W_HYGJ2BCXY_L1_1.fq.gz 
44767
This adaptor was found: >multiplexing-forward, GATCGGAAGAGCACACGTCT
39810
This adaptor was found: >PPErc/2, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
39810
This adaptor was found: >truseq-forward-contam, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
$ bash ../adap_ID.sh Zamp_250_DSW56586-W_HYGJ2BCXY_L1_2.fq.gz 
38690
This adaptor was found: >truseq-reverse-contam, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
38932
This adaptor was found: >solexa-forward, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
(same output as before)
$ cat adaptors.Zamp_250_DSW56586-W_HYGJ2BCXY_L1_1.fq.gz.fa adaptors.Zamp_250_DSW56586-W_HYGJ2BCXY_L1_2.fq.gz.fa ~/TruSeq2-PE.fa > Tru_adap_adapters_Zamp_250.fa
$ module load singularity/2.6.0
$ singularity shell trimmomatic.simg 
Singularity: Invoking an interactive shell within container...
Singularity trimmomatic.simg:~> java -jar /tools/trimmomatic/trimmomatic-0.36.jar PE -threads 12 ~/Zamp_250/Zamp_250_DSW56586-W_HYGJ2BCXY_L1_1.fq.gz ~/Zamp_250/Zamp_250_DSW56586-W_HYGJ2BCXY_L1_2.fq.gz -baseout ~/Zamp_250/Zamp_250_Tru_adap.fq ILLUMINACLIP:/home/nowakvi/Zamp_250/Tru_adap_adapters_Zamp_250.fa:2:30:10:4:4:/true TRAILING:9 SLIDINGWINDOW:4:15 MINLEN:36
...
ILLUMINACLIP: Using 1 prefix pairs, 10 forward/reverse sequences, 0 forward only sequences, 1 reverse only sequences
Quality encoding detected as phred33
Input Read Pairs: 25162970 Both Surviving: 18974410 (75.41%) Forward Only Surviving: 6146304 (24.43%) Reverse Only Surviving: 27570 (0.11%) Dropped: 14686 (0.06%)
TrimmomaticPE: Completed successfully
(23.41% less surviving for both)
```
####meta-SPades assembly
```shell
$ sbatch sbatch_scripts/Zamp_250_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500G
#SBATCH --partition=main
#SBATCH --time=1-12:00
#SBATCH -o /home/nowakvi/SPAdes4.out
#SBATCH -e /home/nowakvi/SPAdes4.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --meta --threads 48 --memory 500 -k 21,33,55,77,99,127 --pe1-1 ~/Zamp_250/Zamp_250_Tru_adap_1P.fq --pe1-2 ~/Zamp_250/Zamp_250_Tru_adap_2P.fq -o ~/Zamp_250_Tru_adap_meta_SPAdes
""
```
- finsihed without warnings
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| #contigs | 610748 |
| #contigs (>= 0 bp) | 1292838 |
| #contigs (>= 1000 bp) | 63096 |
| #contigs (>= 5000 bp) | 249 |
| #contigs (>= 10000 bp) | 52 |
| #contigs (>= 25000 bp) | 2 |
| #contigs (>= 50000 bp) | 0 |
| Largest contig | 26536 |
| Total length | 441609279 |
| Total length (>= 0 bp) | 731092925 |
| Total length (>= 1000 bp) | 85057041 |
| Total length (>= 5000 bp) | 1989611 |
| Total length (>= 10000 bp) | 733405 |
| Total length (>= 25000 bp) | 52361 |
| Total length (>= 50000 bp) | 0 |
| N50 | 696 |
| N75 | 580 |
| L50 | 230462 |
| L75 | 405094 |
| GC (%) | 43.35 |
| Mismatches | |	
| #N's | 0 |
| #N's per 100 kbp | 0 |


### Assembly of PE_150 and Nanopore data
```shell
$ sbatch sbatch_scripts/Zamp_150_Tru_adap_plus_Zamp_mapped_Nano_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=1000G
#SBATCH --partition=bigmem
#SBATCH --time=1-12:00
#SBATCH -o /nfs/home/nowakvi/150_plus_Zamp_mapped_Nano.out
#SBATCH -e /nfs/home/nowakvi/150_plus_Zamp_mapped_Nano.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --meta --threads 40--memory 1000 -k 21,33,55,77,99,127 --pe1-1 /nfs/scratch/nowakvi/Zamp_150_Tru_adap_1P.fq --pe1-2 /nfs/scratch/nowakvi/Zamp_150_Tru_adap_2P.fq --nanopore /nfs/scratch/nowakvi/final_mapped_Nano_to_Zamp_150_SPAdes.fasta -o /nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Zamp_mapped_Nano_meta_SPAdes
""
```
- finished without warnings
- quast results (default parameters

| Statistics without reference | contigs |
| --- | --- |
| #contigs | 274771 |
| #contigs (>= 0 bp) | 546669 |
| #contigs (>= 1000 bp) | 124531 |
| #contigs (>= 5000 bp) | 12256 |
| #contigs (>= 10000 bp) | 4967 |
| #contigs (>= 25000 bp) | 1631 |
| #contigs (>= 50000 bp) | 619 |
| Largest contig | 2765707 |
| Total length | 525805054 |
| Total length (>= 0 bp) | 621776526 |
| Total length (>= 1000 bp) | 421228225 |
| Total length (>= 5000 bp) | 210311935 |
| Total length (>= 10000 bp) | 160876357 |
| Total length (>= 25000 bp) | 110472675 |
| Total length (>= 50000 bp) | 75882121 |
| N50 | 3008 |
| N75 | 1186 |
| L50 | 26140 |
| L75 | 99798 |
| GC (%) | 56.82 |
| Mismatches | |	
| #N's | 500 |
| #N's per 100 kbp | 0.1 |



### Hybrid assembly of PE_250 with PE_150 meta-SPAdes assembly supplied as trusted contigs (PE250_on_PE150)
```shell
$ sbatch sbatch_scripts/Zamp_250_on_Zamp_150_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500G
#SBATCH --partition=main
#SBATCH --time=1-12:00
#SBATCH -o /home/nowakvi/SPAdes3.out
#SBATCH -e /home/nowakvi/SPAdes3.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --threads 48 -k 21,33,55,77,99,127 --pe1-1 ~/Zamp_250/Zamp_250_Tru_adap_1P.fq --pe1-2 ~/Zamp_250/Zamp_250_Tru_adap_2P.fq --trusted-contigs ~/Zamp_150_Tru_adap_meta_SPAdes/contigs.fasta -o ~/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes
""
```
- finished with these warnings:
```shell
======= SPAdes pipeline finished WITH WARNINGS!

=== Error correction and assembling warnings:
 * 0:31:18.475    17G / 29G   WARN    General                 (kmer_coverage_model.cpp   : 218)   Too many erroneous kmers, the estimates might be unreliable
 * 0:45:11.487     9G / 30G   WARN    General                 (kmer_coverage_model.cpp   : 327)   Valley value was estimated improperly, reset to 25
 * 1:18:56.247    40G / 68G   WARN    General                 (simplification.cpp        : 479)   The determined erroneous connection coverage threshold may be determined improperly
 * 0:55:23.752     7G / 45G   WARN    General                 (kmer_coverage_model.cpp   : 327)   Valley value was estimated improperly, reset to 27
 * 1:04:27.697     7G / 60G   WARN    General                 (kmer_coverage_model.cpp   : 327)   Valley value was estimated improperly, reset to 28
 * 2:41:20.679    33G / 60G   WARN   ScaffoldingUniqueEdgeAna (scaff_supplementary.cpp   :  59)   Less than half of genome in unique edges!
```
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| #contigs | 837749 |
| #contigs (>= 0 bp) | 1538731 |
| #contigs (>= 1000 bp) | 190032 |
| #contigs (>= 5000 bp) | 17851 |
| #contigs (>= 10000 bp) | 6659 |
| #contigs (>= 25000 bp) | 2055 |
| #contigs (>= 50000 bp) | 792
| Largest contig | 1121381 |
| Total length | 1004619775 |
| Total length (>= 0 bp) | 1304113051 |
| Total length (>= 1000 bp) | 575252410 |
| Total length (>= 5000 bp) | 278981443 |
| Total length (>= 10000 bp) | 202721479 |
| Total length (>= 25000 bp) | 134300197 |
| Total length (>= 50000 bp) | 90961553 |
| N50 | 1246 |
| N75 | 700 |
| L50 | 124116 |
| L75 | 407150 |
| GC (%) | 50.05 |
| Mismatches | |	
| #N's | 0 |
| #N's per 100 kbp | 0 |


### Hybrid assembly of PE_250 with the PE_150_plus_Nano meta-SPAdes assembly supplied as trusted contigs (PE250_on_PE150_plus_Nano)
```shell
$ sbatch sbatch_scripts/Zamp_250_and_Nanopore_on_Zamp_150_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500G
#SBATCH --partition=bigmem
#SBATCH --time=1-12:00
#SBATCH -o /nfs/home/nowakvi/Nano_on_prev_250_on_150_SPAdes.out
#SBATCH -e /nfs/home/nowakvi/Nano_on_prev_250_on_150_SPAdes.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --threads 48 --memory 500 -k 21,33,55,77,99,127 --trusted-contigs /nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Nano_meta_SPAdes/contigs.fasta --pe1-1 /nfs/scratch/nowakvi/Zamp_250_Tru_adap_1P.fq --pe1-2 /nfs/scratch/nowakvi/Zamp_250_Tru_adap_2P.fq -o /nfs/scratch/nowakvi/Zamp_250_on_Zamp_150_plus_Nano_meta_SPAdes
""
```
- finished with warnings these warnings:
```shell
=== Error correction and assembling warnings:
 * 0:51:32.300    17G / 29G   WARN    General                 (kmer_coverage_model.cpp   : 218)   Too many erroneous kmers, the estimates might be unreliable
 * 2:14:35.328    40G / 68G   WARN    General                 (simplification.cpp        : 479)   The determined erroneous connection coverage threshold may be determined improperly
 * 1:39:12.241     7G / 45G   WARN    General                 (kmer_coverage_model.cpp   : 327)   Valley value was estimated improperly, reset to 33
 * 1:59:10.115     7G / 60G   WARN    General                 (kmer_coverage_model.cpp   : 327)   Valley value was estimated improperly, reset to 36
 * 1:44:59.891     6G / 60G   WARN    General                 (kmer_coverage_model.cpp   : 327)   Valley value was estimated improperly, reset to 27
 * 6:10:44.657    33G / 60G   WARN   ScaffoldingUniqueEdgeAna (scaff_supplementary.cpp   :  59)   Less than half of genome in unique edges!
```
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| #contigs | 837012 |
| #contigs (>= 0 bp) | 1537336 |
| #contigs (>= 1000 bp) | 190020 |
| #contigs (>= 5000 bp) | 17761 |
| #contigs (>= 10000 bp) | 6565 |
| #contigs (>= 25000 bp) | 2049 |
| #contigs (>= 50000 bp) | 807 |
| Largest contig | 1301649 |
| Total length | 1004988585 |
| Total length (>= 0 bp) | 1304189864 |
| Total length (>= 1000 bp) | 576142958 |
| Total length (>= 5000 bp) | 279904488 |
| Total length (>= 10000 bp) | 203583034 |
| Total length (>= 25000 bp) | 136751924 |
| Total length (>= 50000 bp) | 94024851 |
| N50 | 1249 |
| N75 | 700 |
| L50 | 123545 |
| L75 | 406325 |
| GC (%) | 50.05 |
| Mismatches | |	
| #N's | 0 |
| #N's per 100 kbp | 0 |


### Assembly of PE_150 and PE_250 reads
- meta-SPAdes only accepts one paired-end library, thus PE_150 and PE_250 reads were concatenated
```shell
$ sbatch /nfs/home/nowakvi/sbatch_scripts/Zamp_both_Tru_adap_meta_SPAdes.sh
 ""
 #!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=1000G
#SBATCH --partition=bigmem
#SBATCH --time=1-12:00
#SBATCH -o /nfs/home/nowakvi/both_SPAdes.out
#SBATCH -e /nfs/home/nowakvi/both_SPAdes3.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --threads 40 --memory 1000 -k 21,33,55,77,99,127 --meta --pe1-1 /nfs/scratch/nowakvi/Zamp_both_Tru_adap_1.fq --pe1-2 /nfs/scratch/nowakvi/Zamp_both_Tru_adap_2.fq -o /nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_meta_SPAdes
""
```
- finished with these warnings
```shell
======= SPAdes pipeline finished WITH WARNINGS!

=== Error correction and assembling warnings:
 * 1:33:43.657    34G / 60G   WARN    General                 (pair_info_count.cpp       : 358)   Estimated mean insert size 257.29 is very small compared to read length 250
 * 4:43:07.695    34G / 71G   WARN    General                 (pair_info_count.cpp       : 358)   Estimated mean insert size 257.349 is very small compared to read length 250
======= Warnings saved to /nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_meta_SPAdes/warnings.log
```
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| #contigs | 857815 |
| #contigs (>= 0 bp) | 1612819
| #contigs (>= 1000 bp) | 182821 |
| #contigs (>= 5000 bp) | 13252 |
| #contigs (>= 10000 bp) | 5160 |
| #contigs (>= 25000 bp) | 1635 |
| #contigs (>= 50000 bp) | 618 |
| Largest contig | 1644273 |
| Total length | 953513948 |
| Total length (>= 0 bp) | 1273532229 |
| Total length (>= 1000 bp) | 508123310 |
| Total length (>= 5000 bp) | 218261023 |
| Total length (>= 10000 bp) | 163529057 |
| Total length (>= 25000 bp) | 110322500 |
| Total length (>= 50000 bp) | 75422370 |
| N50 | 1093 |
| N75 | 672 |
| L50 | 152770 |
| L75 | 441976 |
| GC (%) | 50.58 |
| Mismatches | |
| #N's | 500 |
| #N's per 100 kbp | 0.05 |


### Assembly of concatented PE_150 and PE_250 plus Nanopore reads
```shell
$ sbatch sbatch_scripts/Zamp_both_Tru_plus_Nano_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=1000G
#SBATCH --partition=bigmem
#SBATCH --time=1-12:00
#SBATCH -o /nfs/home/nowakvi/both_plus_Nano_SPAdes.out
#SBATCH -e /nfs/home/nowakvi/both_plus_Nano_SPAdes.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --threads 40 --memory 1000 -k 21,33,55,77,99,127 --meta --pe1-1 /nfs/scratch/nowakvi/Zamp_both_Tru_adap_1.fq --pe1-2 /nfs/scratch/nowakvi/Zamp_both_Tru_adap_2.fq --nanopore /nfs/scratch/nowakvi/final_unmapped_Nano_to_MH_SPAdes.fasta -o /nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_plus_Nano_meta_SPAdes
""
```
...
```shell
== Error ==  system call for: "['/home/software/apps/spades/3.12.0/bin/spades-hammer', '/nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_plus_Nano_meta_SPAdes/corrected/configs/config.info']" finished abnormally, err code: -6
- may be due it being on smaller c10n01 node; mem=1000G was not specified in sbatch script
- rerun on 1TB c11n01 nodes with #SBATCH --mem=1000G
5:28:14.902    33G / 71G   INFO    General                 (hybrid_aligning.cpp       : 288)   Aligning long reads with bwa-mem based aligner
<jemalloc>: Error in calloc(): out of memory
```
...
```shell
== Error ==  system call for: "['/home/software/apps/spades/3.12.0/bin/spades-core', '/nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_plus_Nano_meta_SPAdes/K127/configs/config.info', '/nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_plus_Nano_meta_SPAdes/K127/configs/mda_mode.info', '/nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_plus_Nano_meta_SPAdes/K127/configs/meta_mode.info']" finished abnormally, err code: -6
```
- fails when trying to align long reads to assembly


### Hybrid assembly of PE_250 and Nanopore data with PE_150 meta-SPAdes assembly supplied as trusted contigs
```shell
$ sbatch sbatch_scripts/Zamp_250_and_Nanopore_on_Zamp_150_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=1000G
#SBATCH --partition=bigmem
#SBATCH --time=1-12:00
#SBATCH -o /nfs/home/nowakvi/250_plus_Nano_on_150_SPAdes.out
#SBATCH -e /nfs/home/nowakvi/250_plus_Nano_on_150_SPAdes.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --threads 40 --memory 1000 -k 21,33,55,77,99,127 --pe1-1 /nfs/scratch/nowakvi/Zamp_250_Tru_adap_1P.fq --pe1-2 /nfs/scratch/nowakvi/Zamp_250_Tru_adap_2P.fq --trusted-contigs /nfs/scratch/nowakvi/contigs.fasta --nanopore /nfs/scratch/nowakvi/final_unmapped_Nano_to_MH_SPAdes.fasta -o /nfs/scratch/nowakvi/Zamp_250_plus_Nano_on_Zamp_150_Tru_adap_meta_SPAdes
""
```
...
```shell
== Error ==  system call for: "['/home/software/apps/spades/3.12.0/bin/spades-hammer', '/nfs/scratch/nowakvi/Zamp_both_Tru_adap_ID_plus_Nano_meta_SPAdes/corrected/configs/config.info']" finished abnormally, err code: -6
```
- fails during K127  graph construction (displays several warnings)



## Binning

### metaWRAP --maxbin2 --metabat2 of PE250_on_PE150
- run on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with Ubuntu 16.04 and 250GB  magnetic storage
- uses Zamp_both as reference, which is PE_150 and PE_250 concatenated after trimming, as only one reference library can be supplied
```shell
$ source activate miniconda3/envs/metawrap-env2/
$ metaWRAP binning -t 40 -m 160 --metabat2 --maxbin2 -a ~/contigs.fasta -o ~/Zamp_250_on_Zamp_150_bins ~/Zamp_both_Tru_adap_1.fastq ~/Zamp_both_Tru_adap_2.fastq
```
- finished successfully
- metabat2 produced 87 bins
- maxbin2 produced 101 bins

### Autometa of PE250_on_PE150
- run on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with Ubuntu 16.04 and 500GB magnetic storage
```shell
$ make_taxonomy_table.py -p 40 -l 1000 -a ~/contigs.fasta -o ~/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_autometa_taxonomy_tables/
$ run_autometa.py --assembly ~/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_autometa_taxonomy_tables/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_autometa_taxonomy_tables/taxonomy.tab -o ~/Zamp_250_autometa/
$ run_autometa.py --assembly ~/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/taxonomy.tab -o ~/Zamp_250_on_Zamp_150_autometa/
$ cluster_process.py --bin_table ~/Zamp_250_on_Zamp_150_autometa/recursive_dbscan_output.tab --column cluster --fasta ~/Bacteria.fasta --output_dir ~/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_processed_autometa_bins/
'''
- produced 90 bins

### dRep of bin sets for PE250_on_PE150
- run on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with Ubuntu 16.04 and 500GB magnetic storage 
```shell
$  dRep dereplicate ~/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_dRep_dereplicated_bins_CORRECTED/ -p 40 -g ~/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_bins/*.fasta
```
- finished with the following warning
```shell
/home/ubuntu/miniconda3/lib/python3.6/site-packages/sklearn/externals/joblib/externals/cloudpickle/cloudpickle.py:47: DeprecationWarning: the imp module is deprecated in favour of importlib; see the module's documentation for alternative uses
```

### Meta_WRAP of PE_150_plus_Nano
- run on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with Ubuntu 16.04 and 500GB magnetic storage
```shell
$ source activate ~/miniconda3/envs/metawrap-env2/
$ metaWRAP binning -t 40 -m 160 --metabat2 --maxbin2 -a ~/Zamp_150_Nano/contigs.fasta -o ~/Zamp_150_Nano_meta_WRAP/ ~/Zamp_150_Tru_adap_1.fastq ~/Zamp_150_Tru_adap_2.fastq
```
- finished without error
- finished successfully
- maxbin2 found 96 bins
- metabat2 found 81 bins

### Autometa of PE_150_plus_Nanopore
- run on EC2 m4.10xlarge awx instance with Ubuntu 16.04 and 500GB magnetic storage
```shell
$ make_taxonomy_table.py -p 40 -a ~/Zamp_150_Nano/contigs.fasta -l 1000 -o ~/Zamp_150_Nano_taxonomy_tables/
$ run_autometa.py --assembly ~/Zamp_150_Nano_taxonomy_tables/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/Zamp_150_Nano_taxonomy_tables/taxonomy.tab -o ~/Zamp_150_Nano_autometa/
$ cluster_process.py --bin_table ~/Zamp_150_Nano_autometa/recursive_dbscan_output.tab --column cluster --fasta ~/Zamp_150_Nano_taxonomy_tables/Bacteria.fasta --output_dir ~/Zamp_150_Nano_autometa_processed_bins/
```
- produced 101 bins

### dRep of PE_150_plus_Nano
- run on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance  with Ubuntu 16.04 and 250GB magnetic storage
```shell
$ dRep dereplicate ~/Zamp_150_Nano_dereplicated_bins/ -p 40 -g ~/Zamp_150_Nano_bins/*.fasta
```
- finished with the following warning
```shell
/home/ubuntu/miniconda3/lib/python3.6/site-packages/sklearn/externals/joblib/externals/cloudpickle/cloudpickle.py:47: DeprecationWarning: the imp module is deprecated in favour of importlib; see the module's documentation for alternative uses
```



## antiSMASH of dRep dereplicated bins
- run on server (rosalind) running Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-142-generic x86_64)
- uses antiSMASH version 4.2.0 (conda)

### PE150_plus_Nano
```shell
$ sbatch sbatch_scripts/antiSMASH_Zamp_150_Tru_adap_plus_Nano_dereplicated_genomes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_Zamp_150_Tru_adap_plus_Nano_dRep.out
#SBATCH -e /nfs/home/nowakvi/anti_Zamp_150_Tru_adap_plus_Nano_dRep.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_Zamp_150_Tru_adap_plus_Nano_dereplicated_genomes /nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Nano_meta_SPAdes_dereplicated_genomes_/*.fasta
""
```

### PE250_on_PE150_dRep_dereplicated_bins
```shell
$ sbatch sbatch_scripts/antiSMASH_Zamp_250_on_Zamp_150_Tru_dereplicated_genomes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_Zamp_250_on_150_dRep.out
#SBATCH -e /nfs/home/nowakvi/anti_Zamp_250_on_150_dRep.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_Zamp_250_on_Zamp_150_dereplicated_genomes2 /nfs/scratch/nowakvi/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_dereplicated_genomes_CORRECTED/*.fasta
""
```

## antiSMASH of length-filtered (>5kb) contigs
- antiSMASH version 4.1.0 (conda) on raapoi (confusingly I named the conda environment antismash4.2.0)

### PE150_plus_Nano
```shell
$ bash ../fasta_len_filter.sh /nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Nano_meta_SPAdes/contigs.fasta /nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Nano_meta_SPAdes/contigs_len_5000_filtered_.fasta 5000
- 12291 contigs
$ sbatch antiSMASH_Zamp_150_Tru_adap_plus_Nano_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_Zamp_150_Nano.out
#SBATCH -e /nfs/home/nowakvi/anti_Zamp_150_Nano.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_Zamp_150_Tru_adap_plus_Nano_meta_SPAdes/ /nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Nano_meta_SPAdes/contigs_len_5000_filtered_.fasta
""
```

### PE250_on_PE150
```shell
$ bash ~/fasta_len_filter.sh ./Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes/contigs.fasta ./Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes/contigs_len_5000_filtered.fasta 5000
- 17851 contigs
$ sbatch antiSMASH_Zamp_250_on_Zamp_150_Tru_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_Zamp_250_on_150.out
#SBATCH -e /nfs/home/nowakvi/anti_Zamp_250_on_150.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes /nfs/scratch/nowakvi/Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes/contigs_len_5000_filtered.fasta
""
```


## Sponge taxonomy:

### PE150_plus_Nano:
```shell
$ barrnap --threads 12 --kingdom euk --outseq Zamp_150_Tru_adap_plus_Nano_meta_SPAdes_barrnap_outseqs.fasta contigs.fasta
```
- identified 293 sequences

### PE250_on_PE150 assembly:
```shell
$ barrnap --threads 12 --kingdom euk --outseq Zamp_250_on_Zamp_150_Tru_adap_meta_SPAdes_barrnap_outseqs.fasta contigs.fasta
```


## Data generation for the coverage over GC blobplot
```shell
# calculate gc content of each contig (from Albersten et. al 2013)
$ git clone git://github.com/MadsAlbertsen/multi-metagenome.git
$ perl ~/multi-metagenome/R.data.generation/calc.gc.pl -i assembly.fa -o assembly.gc.tab
# create a column with coverag info from SPAdes contig name
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "coverage"} {print $6}' > coverage_column.tab
# checked that wc -l is the same
$ paste -d '\t' assembly_copy.gc.tab coverage_column.tab > assembly_copy.gc.coverage.tab
# create length table
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "length"} {print $4}' > assembly_length.tab
# checked that wc -l is the same
$ paste -d '\t' assembly_copy.gc.coverage.tab assembly_length.tab > assembly_copy.gc.coverage.length.tab
# creating table with contig per bin info
$ grep "^>" *.fasta | sed 's/:>/\t/' | awk -F'_' 'BEGIN {print "bin""\t""contig"} {print $0}' > contigs_per_bin.tsv
```
- joining dataframes on raapoi running R/3.5.1
```{r}
> gc_coverage <- read.delim("/nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Nano_meta_SPAdes_plot_data/assembly_copy.gc.coverage.length.tab", header = TRUE, sep = "\t")
> contigs_per_bin <- read.delim("/nfs/scratch/nowakvi/Zamp_150_Tru_adap_plus_Nano_meta_SPAdes_plot_data/contigs_per_bin.tsv", header = TRUE, sep = "\t")
# checked with head and tail that every row has all values
> table(gc_coverage$contig %in% contigs_per_bin$contig)
 FALSE   TRUE 
532348  14185
> i <- match(gc_coverage$contig, contigs_per_bin$contig)
> table(is.na(i))
 FALSE   TRUE 
 14185 532348
> gc_coverage$bin <- contigs_per_bin$bin[i]
> head(gc_coverage, 5)
                              contig    gc  coverage  length
1 NODE_1_length_2765707_cov_4.308384 62.21  4.308384 2765707
2 NODE_2_length_926060_cov_11.452145 48.17 11.452145  926060
3  NODE_3_length_794533_cov_2.366468 48.97  2.366468  794533
4  NODE_4_length_720150_cov_5.971225 60.53  5.971225  720150
5  NODE_5_length_681301_cov_3.321949 63.89  3.321949  681301
                             bin
1 cluster_DBSCAN_round14_0.fasta
2       bin.18.fa.metabat2.fasta
3        bin.30.fa.maxbin2.fasta
4        bin.12.fa.maxbin2.fasta
5  cluster_DBSCAN_round2_1.fasta
# above workflow can be boiled down to the command "gc_coverage$bin <- contigs_per_bin$bin[match(gc_coverage$contig, contigs_per_bin$contig)]"
# adding marker lineage (from dRep check-m results) to final data in R on macbook as above
>  data <- read.delim("~/Documents/Sequencing/CS_783/Zamp_150_plus_Nano_dRep_dereplicated_bins_plot_data.tsv", header=TRUE, sep="\t")
> bin_taxonomy <- read.delim("~/Documents/Sequencing/CS_783/check_m_Zamp_150_Tru_adap_plus_Nano_meta_SPAdes_dRep_dereplicated_bins/results.tsv", header=TRUE, sep="\t")
# checked head and tail
> data$marker_lineage <- bin_taxonomy$Marker.lineage[match(data$bin, bin_taxonomy$Bin.Id,)]
> write.table(gc_coverage, file="/nfs/scratch/nowakvi/~/Documents/Sequencing/CS_783/Zamp_150_plus_Nano_dRep_dereplicated_bins_plot_data.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
# plotting data with ggplot2 on MacBook (macOS  10.14.2) with R version 3.4.3: 
> data <- read.delim("~/Documents/Sequencing/CS_783/Zamp_150_plus_Nano_dRep_dereplicated_bins_plot_data.tsv", header=TRUE, sep="\t")
> library(ggplot2)
> ggplot(data[!is.na(data$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 500)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
# saving to desktop
> Zamp_150_plus_Nano_plot <- ggplot(data[!is.na(data$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 500)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19))) 
> pdf(file = "~/Documents/Sequencing/CS_783/Zamp_150_plus_Nano_dRep_dereplicated_bins_plot.pdf")
> plot(Zamp_150_plus_Nano_plot)
> dev.off()
```


## Summarizing the number of bins per lineage from file generated for blobplot
$ cut -f 6,5 Zamp_150_plus_Nano_dRep_dereplicated_bins_plot_data.tsv | sort -su | cut -f 2 | sort | uniq -c
      2 c__Alphaproteobacteria (UID3305)
      4 c__Gammaproteobacteria (UID4443)
      1 c__Spirochaetia (UID2496)
      1 k__Archaea (UID2)
     12 k__Bacteria (UID1452)
      3 k__Bacteria (UID1453)
      4 k__Bacteria (UID203)
     10 k__Bacteria (UID2495)
      8 k__Bacteria (UID3187)
      1 marker_lineage
      1 NA
      1 o__Rhodospirillales (UID3754)
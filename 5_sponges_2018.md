# Readme for the analyses of 5 Tongan sponges

### Summary of algorithms and operation system used
- Jobs were run on the Victoria University of Wellington high-performance computing cluster (raapoi) running CentOS Linux release 7.6.1810 unless otherwise specified
- slurm 18.08.4
- Singularity  2.6.0
- Trimmomatic  0.36 (Singularity image)
- quast 5.0.0
- SPAdes 3.12.0
- metaWRAP 1.0.5 (conda install)
- autometa (commit c6e398e)
- barrnap 0.9
- dRep 2.2.3
- checkm 1.0.13
- BBTools 38.31

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

### CS200

#### Adapter detection and trimming
```shell
$ srun --pty -c 12 --mem=120G bash
$ bash ../adap_ID.sh CS200_R1.fq.gz 
2682
This adaptor was found: >multiplexing-forward, GATCGGAAGAGCACACGTCT
1311
This adaptor was found: >PPErc/2, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
1311
This adaptor was found: >truseq-forward-contam, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
$ bash ../adap_ID.sh CS200_R2.fq.gz 
1167
This adaptor was found: >solexa-forward, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
$ cat adaptors.CS200_R1.fq.gz.fa adaptors.CS200_R2.fq.gz.fa > adap_ID_Tru_adapters_CS200.fa
$ cat ~/TruSeq2-PE.fa >> adap_ID_Tru_adapters_CS200.fa
$ module load singularity/2.6.0
$ singularity shell trimmomatic.simg 
Singularity: Invoking an interactive shell within container...
Singularity trimmomatic.simg:~> java -jar /tools/trimmomatic/trimmomatic-0.36.jar PE -threads 12 ~/CS200/CS200_R1.fq.gz ~/CS200/CS200_R2.fq.gz -baseout CS200_Tru_adap.fq ILLUMINACLIP:/home/nowakvi/CS200/adap_ID_Tru_adapters_CS200.fa:2:30:10:4:4:/true TRAILING:9 SLIDINGWINDOW:4:15 MINLEN:36
```
...
```shell
ILLUMINACLIP: Using 1 prefix pairs, 9 forward/reverse sequences, 0 forward only sequences, 1 reverse only sequences
Quality encoding detected as phred33
Input Read Pairs: 97472750 Both Surviving: 90626569 (92.98%) Forward Only Surviving: 6575050 (6.75%) Reverse Only Surviving: 175314 (0.18%) Dropped: 95817 (0.10%)
TrimmomaticPE: Completed successfully
```

#### meta-SPAdes
```shell
$ sbatch sbatch_scripts/CS200_Tru_adap_meta_SPAdes.sh
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
spades.py --meta --threads 48 --memory 500 -k 21,33,55,77,99,127 --pe1-1 /scratch_tmp/nowakvi/CS200/CS200_Tru_adap_1P.fq --pe1-2 /scratch_tmp/nowakvi/CS200/CS200_Tru_adap_2P.fq -o /scratch_tmp/nowakvi/CS200/CS200_Tru_adap_meta_SPAdes
""
```
- finished without warnings
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| # contigs | 238671 |
| # contigs (>= 0 bp) | 509312 |
| # contigs (>= 1000 bp) | 103228 |
| # contigs (>= 5000 bp) | 16715 |
| # contigs (>= 10000 bp) | 7948 |
| # contigs (>= 25000 bp) | 2656 |
| # contigs (>= 50000 bp) | 1006 |
| Largest contig | 5167676 |
| Total length | 574522577 |
| Total length (>= 0 bp) | 669144733 |
| Total length (>= 1000 bp) | 481113822 |
| Total length (>= 5000 bp) | 316531671 |
| Total length (>= 10000 bp) | 255976842 |
| Total length (>= 25000 bp) | 175281647 |
| Total length (>= 50000 bp) | 118494071 |
| N50 | 6937 |
| N75 | 1507 |
| L50 | 11727 |
| L75 | 61735 |
| GC (%) | 58.98 |
| Mismatches | |	
| # N's | 300 |
| # N's per 100 kbp | 0.05 |


### CS202

#### Adapter dtection and trimming
```shell
$ srun --pty -c 12 --mem=120G bash
$ cd CS202/
$ bash ../adap_ID.sh CS202_R1.fq.gz 
2064
This adaptor was found: >multiplexing-forward, GATCGGAAGAGCACACGTCT
1042
This adaptor was found: >PPErc/2, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
1042
This adaptor was found: >truseq-forward-contam, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
nowakvi@cadgridhigh01:~/CS202$ bash ../adap_ID.sh CS202_R2.fq.gz 
1029
This adaptor was found: >solexa-forward, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
$ cat adaptors.CS202_R1.fq.gz.fa adaptors.CS202_R2.fq.gz.fa ../TruSeq2-PE.fa > Tru_adap_ID_adapters_CS202.fa
$ module load singularity/2.6.0 
$ singularity shell trimmomatic.simg 
Singularity: Invoking an interactive shell within container...
Singularity trimmomatic.simg:~> java -jar /tools/trimmomatic/trimmomatic-0.36.jar PE -threads 12 ~/CS202/CS202_R1.fq.gz ~/CS202/CS202_R2.fq.gz -baseout ~/CS202/CS202_Tru_adap_2.fq ILLUMINACLIP:/home/nowakvi/CS202/Tru_adap_ID_adapters_CS202.fa:2:30:10:4:4:/true TRAILING:9 SLIDINGWINDOW:4:15 MINLEN:36
```
...
```shell
ILLUMINACLIP: Using 1 prefix pairs, 9 forward/reverse sequences, 0 forward only sequences, 1 reverse only sequences
Quality encoding detected as phred33
Input Read Pairs: 74789106 Both Surviving: 69453096 (92.87%) Forward Only Surviving: 5117229 (6.84%) Reverse Only Surviving: 141537 (0.19%) Dropped: 77244 (0.10%)
TrimmomaticPE: Completed successfully
```

####meta-SPAdes
```shell
$ sbatch sbatch_scripts/CS202_Tru_adap_meta_SPAdes.sh
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
spades.py --meta --threads 48 --memory 500 -k 21,33,55,77,99,127 --pe1-1 ~/CS202/CS202_Tru_adap_2_1P.fq --pe1-2 ~/CS202/CS202_Tru_adap_2_2P.fq -o ~/CS202_Tru_adap_meta_SPAdes
rm -r ~/CS202_Tru_adap_meta_SPAdes/K*
rm -r ~/CS202_Tru_adap_meta_SPAdes/corrected/
rm -r ~/CS202_Tru_adap_meta_SPAdes/tmp
rm -r ~/CS202_Tru_adap_meta_SPAdes/misc
""
```
- finished without warnings
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| # contigs | 399539 |
| # contigs (>= 0 bp) | 859879 |
| # contigs (>= 1000 bp) | 174363 |
| # contigs (>= 5000 bp) | 13069 |
| # contigs (>= 10000 bp) | 5350 |
| # contigs (>= 25000 bp) | 1969 |
| # contigs (>= 50000 bp) | 793 |
| Largest contig | 736882 |
| Total length | 667142309 |
| Total length (>= 0 bp) | 821678712 |
| Total length (>= 1000 bp) | 509765864 |
| Total length (>= 5000 bp) | 218385925 |
| Total length (>= 10000 bp) | 166499697 |
| Total length (>= 25000 bp) | 115315894 |
| Total length (>= 50000 bp) | 74308892 |
| N50 | 2200 |
| N75 | 1039 |
| L50 | 50409 |
| L75 | 165130 |
| GC (%) | 52.64 |
| Mismatches | |	
| # N's | 800 |
| # N's per 100 kbp | 0.12 |


### CS203

#### Adapter detection and trimming
```shell
$ srun --pty -c 12 --mem=120G bash
$ bash ~/adap_ID.sh CS203_R1.fq.gz 
1980
This adaptor was found: >multiplexing-forward, GATCGGAAGAGCACACGTCT
1038
This adaptor was found: >PPErc/2, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
1038
This adaptor was found: >truseq-forward-contam, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
$ bash ~/adap_ID.sh CS203_R2.fq.gz 
940
This adaptor was found: >solexa-forward, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
$ cat adaptors.CS203_R1.fq.gz.fa adaptors.CS203_R2.fq.gz.fa ~/TruSeq2-PE.fa > Tru_adap_adapters_CS203.fa
$ module load singularity/2.6.0 
$ singularity shell trimmomatic.simg 
Singularity: Invoking an interactive shell within container...
Singularity trimmomatic.simg:~/CS203> java -jar /tools/trimmomatic/trimmomatic-0.36.jar PE -threads 12 ~/CS203/CS203_R1.fq.gz ~/CS203/CS203_R2.fq.gz -baseout ~/CS203/CS203_Tru_adap_2.fq ILLUMINACLIP:/home/nowakvi/CS203/Tru_adap_adapters_CS203.fa:2:30:10:4:4:/true TRAILING:9 SLIDINGWINDOW:4:15 MINLEN:36
```
...
```shell
ILLUMINACLIP: Using 1 prefix pairs, 9 forward/reverse sequences, 0 forward only sequences, 1 reverse only sequences
Quality encoding detected as phred33
Input Read Pairs: 81926823 Both Surviving: 76997998 (93.98%) Forward Only Surviving: 4675441 (5.71%) Reverse Only Surviving: 169035 (0.21%) Dropped: 84349 (0.10%)
TrimmomaticPE: Completed successfully
```

#### meta-SPAdes
```shell
$ sbatch sbatch_scripts/CS203_True_adap_meta_SPAdes.sh 
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500G
#SBATCH --partition=main
#SBATCH --time=1-12:00
#SBATCH -o /home/nowakvi/SPAdes2.out
#SBATCH -e /home/nowakvi/SPAdes2.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --meta --threads 48 --memory 500 -k 21,33,55,77,99,127 --pe1-1 ~/CS203/CS203_Tru_adap_2_1P.fq --pe1-2 ~/CS203/CS203_Tru_adap_2_2P.fq -o ~/CS203_Tru_adap_meta_SPAdes
rm -r ~/CS203_Tru_adap_meta_SPAdes/K*
rm -r ~/CS203_Tru_adap_meta_SPAdes/corrected/
rm -r ~/CS203_Tru_adap_meta_SPAdes/tmp
rm -r ~/CS203_Tru_adap_meta_SPAdes/misc
""
```
- finished without warnings
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| # contigs | 426214 |
| # contigs (>= 0 bp) | 998520 |
| # contigs (>= 1000 bp) | 187610 |
| # contigs (>= 5000 bp) | 17794 |
| # contigs (>= 10000 bp) | 7296 |
| # contigs (>= 25000 bp) | 2436 |
| # contigs (>= 50000 bp) | 984 |
| Largest contig | 601942 |
| Total length | 775596201 |
| Total length (>= 0 bp) | 966016814 |
| Total length (>= 1000 bp) | 610356293 |
| Total length (>= 5000 bp) | 291315259 |
| Total length (>= 10000 bp) | 220051412 |
| Total length (>= 25000 bp) | 146745103 |
| Total length (>= 50000 bp) | 96300168 |
| N50 | 2731 |
| N75 | 1126 |
| L50 | 44774 |
| L75 | 160575 |
| GC (%) | 58.71 |
| Mismatches | |	
| # N's | 5300 |
| # N's per 100 kbp | 0.68 |


### CS204

#### Adapter detection and trimming
```shell
$ srun --pty -c 12 --mem=120G bash
$ bash ~/adap_ID.sh CS204_R1.fq.gz 
1650
This adaptor was found: >multiplexing-forward, GATCGGAAGAGCACACGTCT
867
This adaptor was found: >PPErc/2, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
867
This adaptor was found: >truseq-forward-contam, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
$ bash ~/adap_ID.sh CS204_R2.fq.gz 
863
This adaptor was found: >solexa-forward, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
$ cat adaptors.CS204_R1.fq.gz.fa adaptors.CS204_R2.fq.gz.fa ~/TruSeq2-PE.fa > Tru_adap_adapters_CS204.fa
$ module load singularity/2.6.0 
$ singularity shell trimmomatic.simg 
Singularity: Invoking an interactive shell within container...
Singularity trimmomatic.simg:~> java -jar /tools/trimmomatic/trimmomatic-0.36.jar PE -threads 12 ~/CS204/CS204_R1.fq.gz ~/CS204/CS204_R2.fq.gz -baseout ~/CS204/CS204_Tru_adap.fq ILLUMINACLIP:/home/nowakvi/CS204/Tru_adap_adapters_CS204.fa:2:30:10:4:4:/true TRAILING:9 SLIDINGWINDOW:4:15 MINLEN:36
```
...
```shell
ILLUMINACLIP: Using 1 prefix pairs, 9 forward/reverse sequences, 0 forward only sequences, 1 reverse only sequences
Quality encoding detected as phred33
Input Read Pairs: 68468774 Both Surviving: 64514409 (94.22%) Forward Only Surviving: 3746119 (5.47%) Reverse Only Surviving: 137415 (0.20%) Dropped: 70831 (0.10%)
TrimmomaticPE: Completed successfully
```

#### meta-SPAdes
```shell
$ sbatch sbatch_scripts/CS204_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500G
#SBATCH --partition=main
#SBATCH --time=1-12:00
#SBATCH -o /home/nowakvi/SPAdes2.out
#SBATCH -e /home/nowakvi/SPAdes2.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --meta --threads 48 --memory 500 -k 21,33,55,77,99,127 --pe1-1 ~/CS204/CS204_Tru_adap_1P.fq --pe1-2 ~/CS204/CS204_Tru_adap_2P.fq -o ~/CS204_Tru_adap_meta_SPAdes
rm -r ~/CS204_Tru_adap_meta_SPAdes/K*
rm -r ~/CS204_Tru_adap_meta_SPAdes/corrected/
rm -r ~/CS204_Tru_adap_meta_SPAdes/tmp
rm -r ~/CS204_Tru_adap_meta_SPAdes/misc
""
```
- finished without warnings
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| # contigs | 397797 |
| # contigs (>= 0 bp) | 861728 |
| # contigs (>= 1000 bp) | 183684 |
| # contigs (>= 5000 bp) | 17737 |
| # contigs (>= 10000 bp) | 6478 |
| # contigs (>= 25000 bp) | 1861 |
| # contigs (>= 50000 bp) | 677 |
| Largest contig | 725958 |
| Total length | 717337886 |
| Total length (>= 0 bp) | 871828197 |
| Total length (>= 1000 bp) | 568125031 |
| Total length (>= 5000 bp) | 253933041 |
| Total length (>= 10000 bp) | 177796170 |
| Total length (>= 25000 bp) | 109278600 |
| Total length (>= 50000 bp) | 68983871 |
| N50 | 2631 |
| N75 | 1141 |
| L50 | 47641 |
| L75 | 155463 |
| GC (%) | 57.76 |
| Mismatches | |	
| # N's | 3900 |
| # N's per 100 kbp | 0.54 |


### CS211

#### Adapter detection and trimming
```shell
$ srun --pty -c 12 --mem=120G bash
$ bash ~/adap_ID.sh CS211_R1.fq.gz 
2307
This adaptor was found: >multiplexing-forward, GATCGGAAGAGCACACGTCT
1199
This adaptor was found: >PPErc/2, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
1199
This adaptor was found: >truseq-forward-contam, AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
nowakvi@cadgridlow01:/scratch_tmp/nowakvi/CS211$ bash ~/adap_ID.sh CS211_R2.fq.gz 
1108
This adaptor was found: >solexa-forward, AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
$ cat adaptors.CS211_R1.fq.gz.fa adaptors.CS211_R2.fq.gz.fa ~/TruSeq2-PE.fa > Tru_adap_adapters_CS211.fa
$ module load singularity/2.6.0
$ singularity shell trimmomatic.simg 
Singularity: Invoking an interactive shell within container...
Singularity trimmomatic.simg:~> java -jar /tools/trimmomatic/trimmomatic-0.36.jar PE -threads 12 ~/CS211/CS211_R1.fq.gz ~/CS211/CS211_R2.fq.gz -baseout ~/CS211/CS211_Tru_adap.fq ILLUMINACLIP:/home/nowakvi/CS211/Tru_adap_adapters_CS211.fa:2:30:10:4:4:/true TRAILING:9 SLIDINGWINDOW:4:15 MINLEN:36
```
...
```shell
ILLUMINACLIP: Using 1 prefix pairs, 9 forward/reverse sequences, 0 forward only sequences, 1 reverse only sequences
Quality encoding detected as phred33
Input Read Pairs: 93447634 Both Surviving: 87579326 (93.72%) Forward Only Surviving: 5608706 (6.00%) Reverse Only Surviving: 174940 (0.19%) Dropped: 84662 (0.09%)
TrimmomaticPE: Completed successfully
```

#### meta-SPAdes:
```shell
$ sbatch sbatch_scripts/CS211_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500G
#SBATCH --partition=main
#SBATCH --time=1-12:00
#SBATCH -o /home/nowakvi/SPAdes2.out
#SBATCH -e /home/nowakvi/SPAdes2.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=vincentnowak93@gmail.com

module load spades/3.12.0
spades.py --meta --threads 48 --memory 500 -k 21,33,55,77,99,127 --pe1-1 ~/CS211/CS211_Tru_adap_1P.fq --pe1-2 ~/CS211/CS211_Tru_adap_2P.fq -o ~/CS211_Tru_adap_meta_SPAdes
""
```
- finished without warnings
- quast results (default params)

| Statistics without reference | contigs |
| --- | --- |
| # contigs | 440822 |
| # contigs (>= 0 bp) | 1094204 |
| # contigs (>= 1000 bp) | 183455 |
| # contigs (>= 5000 bp) | 20253 |
| # contigs (>= 10000 bp) | 7878 |
| # contigs (>= 25000 bp) | 2047 |
| # contigs (>= 50000 bp) | 642 |
| Largest contig | 420250 |
| Total length | 754610713 |
| Total length (>= 0 bp) | 977104631 |
| Total length (>= 1000 bp) | 577200279 |
| Total length (>= 5000 bp) | 274487893 |
| Total length (>= 10000 bp) | 190041088 |
| Total length (>= 25000 bp) | 102709048 |
| Total length (>= 50000 bp) | 54682750 |
| N50 | 2557 |
| N75 | 1045 |
| L50 | 49999 |
| L75 | 172454 |
| GC (%) | 61.85 |
| Mismatches | |	
| # N's | 600 |
| # N's per 100 kbp | 0.08 |



## Binning

### metaWRAP --maxbin2 --metabat2

#### CS200
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 250GB  magnetic storage
```shell
$ source activate miniconda3/envs/metawrap-env2/
(metawrap-env2) $ metaWRAP binning -t 40 -m 160 --maxbin2 -a ~/contigs.fasta -o ~/CS200_Tru_adap_meta_SPAdes_metawrap_bins/ ~/CS200_Tru_adap_1.fastq ~/CS200_Tru_adap_2.fastq
```
- finished successfully
- metabat2 found 117 bins
- maxbin2 found 119 bins

#### CS202
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 250GB  magnetic storage
```shell
$ source activate miniconda3/envs/metawrap-env2/
(metawrap-env2) ubuntu@ip-172-31-9-251:~$ metaWRAP binning -t 40 -m 160 --metabat2 --maxbin2 -a ~/contigs.fasta -o ~/CS202_Tru_adap_meta_SPAdes_bins ~/CS202_Tru_adap_copy_1.fastq ~/CS202_Tru_adap_copy_2.fastq
'''
- finished successfully
- metabat2 found 87 bins
- maxbin2 found 121 bins

#### CS203
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 250GB  magnetic storage
```shell
$ source activate miniconda3/envs/metawrap-env2/
(metawrap-env2) $ metaWRAP binning -t 40 -m 160 --metabat2 --maxbin2 -a ~/contigs.fasta -o ~/CS203_Tru_adap_meta_SPAdes_bins ~/CS203_Tru_adap_copy_1.fastq ~/CS203_Tru_adap_copy_2.fastq 
```
- finished successfully
- metabat2 produced 118 bins
- maxbin2 produced 114 bins

#### CS204
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 250GB  magnetic storage
```shell
$ source activate miniconda3/envs/metawrap-env2/
(metawrap-env2) $ metaWRAP binning -t 40 -m 160 --metabat2 --maxbin2 -a ~/contigs.fasta -o ~/CS204_Tru_adap_meta_SPAdes_bins ~/CS204_Tru_adap_copy_1.fastq ~/CS204_Tru_adap_copy_2.fastq 
```
- finished successfully
- metabat2 produced 114 bins
- maxbin2 produced 122 bins

#### CS211
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 250GB  magnetic storage
```shell
$ source activate miniconda3/envs/metawrap-env2/
(metawrap-env2) $ metaWRAP binning -t 40 -m 160 --metabat2 --maxbin2 -a ~/contigs.fasta -o ~/CS211_Tru_adap_meta_SPAdes_bins ~/CS211_Tru_adap_copy_1.fastq ~/CS211_Tru_adap_copy_2.fastq
```
- finished successfully
- metabat2 produced 122 bins
- maxbin2 produced 138 bins

### Autometa

#### CS200
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 500GB  magnetic storage
```shell
$ make_taxonomy_table.py -p 40 -a ~/CS200_meta/contigs.fasta -l 1000 -o ~/CS200_autometa/
$ run_autometa.py --assembly ~/CS200_autometa/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/CS200_autometa/taxonomy.tab -o ~/CS200_autometa_bins
$ cluster_process.py --bin_table recursive_dbscan_output.tab --column cluster --fasta Bacteria.fasta --output_dir ~/CS200_final_autometa_bins/
```
- produced 153 bins

#### CS202
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 500GB  magnetic storage
```shell
$ make_taxonomy_table.py -p 40 -a ~/CS202_meta/contigs.fasta -l 1000 -o ~/CS202_autometa/
$ run_autometa.py --assembly ~/CS202_autometa/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/CS202_autometa/taxonomy.tab -o ~/CS202_autometa_bins
$ cluster_process.py --bin_table recursive_dbscan_output.tab --column cluster --fasta Bacteria.fasta --output_dir ~/CS202_Tru_adap_meta_SPAdes_autometa_bins/
```
- produced 103 bins

#### CS203
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 500GB  magnetic storage
```shell
$ make_taxonomy_table.py -p 40 -a ~/CS203_meta/contigs.fasta -l 1000 -o ~/CS203_autometa/
$ run_autometa.py --assembly ~/CS203_autometa/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/CS203_autometa/taxonomy.tab -o ~/CS203_autometa_bins
$ cluster_process.py --bin_table recursive_dbscan_output.tab --column cluster --fasta Bacteria.fasta --output_dir ~/CS203_processed_autometa_bins/
```
- produced 126 bins

#### CS204
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 500GB  magnetic storage
```shell
$ make_taxonomy_table.py -p 40 -a ~/CS204_meta/contigs.fasta -l 1000 -o ~/CS204_autometa/
$ run_autometa.py --assembly ~/CS204_autometa/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/CS204_autometa/taxonomy.tab -o ~/CS204_autometa_bins
$ cluster_process.py --bin_table recursive_dbscan_output.tab --column cluster --fasta Bacteria.fasta --output_dir ~/CS204_processed_autometa_bins/
```
- produced 98 bins

#### CS211
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 1000GB magnetic storage
```shell
$ make_taxonomy_table.py -p 40 -a ~/contigs.fasta -l 1000 -o ~/CS211_autometa/
$ run_autometa.py --assembly ~/CS211_autometa/Bacteria.fasta --processors 40 --length_cutoff 1000 --taxonomy_table ~/CS211_autometa/taxonomy.tab -o ~/CS211_autometa_bins
$ cluster_process.py --bin_table recursive_dbscan_output.tab --column cluster --fasta Bacteria.fasta --output_dir ~/CS211_processed_autometa_bins/
```
- produced 123 bins

### dRep dereplication
#### CS200
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 500GB  magnetic storage
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
- copied all bin files into one directory and renamed them to include the binning algorithm and .fasta in name
```shell
$ dRep dereplicate ~/drep_dereplication_wkdir/ -p 40 -g ~/drep_dereplication/*.fasta
```
- produced 76 bins

#### CS202
- on EC2 m4.10xlarge (40vCPUs, 160GB) aws instance with 500GB  magnetic storage
- copied all bin files into one directory and renamed them to include the binning algorithm and .fasta in name
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
```shell
$ dRep dereplicate ~/CS202_dRep_dereplicated_bins/ -p 40 -g ~/CS202_3_binsets/*.fasta
```
- produced 55 bins

#### CS203
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
- copied all bin files into one directory and renamed them to include the binning algorithm and .fasta in name
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
```shell
$ dRep dereplicate ~/drep_CS203_wkdir/ -p 40 -g ~/CS203_bins/*.fasta
```
- produced 52 bins

#### CS204
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
- copied all bin files into one directory and renamed them to include the binning algorithm and .fasta in name
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
```shell
$ dRep dereplicate ~/CS204_drep_wkdir/ -p 40 -g ~/CS204_bins/*.fasta
```
- produced 50 bins

#### CS211
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
- copied all bin files into one directory and renamed them to include the binning algorithm and .fasta in name
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
```shell
$ dRep dereplicate ~/CS211_drep_wkdir/ -p 40 -g ~/CS211_bins/*.fasta
```
- produced 48 bins



## dRep compare (including CS_783_Zamp)
- deleted unclustered file from autometa and metabat2 (maxbin2 does not appear to have one)
- added sponge name in front of bin name and copied all into one folder
```shell
$ sbatch sbatch_scripts/dRep_compare_6_sponges.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=1000G
#SBATCH --partition=bigmem
#SBATCH --time=12:00:00
#SBATCH -o /nfs/home/nowakvi/dRep_compare_6_sponges.out
#SBATCH -e /nfs/home/nowakvi/dRep_compare_6_sponges.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

module load dRep/2.2.4
dRep compare /nfs/scratch/nowakvi/6_sponges_dreplicated_genomes_dRep_compare/ -p 40 -g /nfs/scratch/nowakvi/6_sponges_dreplicated_genomes/*.fasta
""
```



## checkM lineage-specific workflow
```shell
$ sbatch sbatch_scripts/checkM_6_sponges_lineage_wf_reduced.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/6_sponges_checkM_lineage_wf.out
#SBATCH -e /nfs/home/nowakvi/6_sponges_checkM_lineage_wf.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate py27
checkm lineage_wf -x fasta -t 24 -r /nfs/scratch/nowakvi/6_sponges_dreplicated_genomes/ /nfs/scratch/nowakvi/6_sponges_dreplicated_genomes_checkM_lineage_wf/
source deactivate
""
```



## antiSMASH

### dRep dereplicated bins
- run on server (rosalind) running Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-142-generic x86_64)
- uses antiSMASH version 4.2.0 (conda)

#### CS200
```shell
$ for f in /home/metamax/Vincent/CS200_dRep_dereplicated_bins/*.fasta; do run_antismash $f /home/metamax/Vincent/CS200_dRep_dereplicated_bins_antismash_output -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs; done
```

#### CS202
```shell
$ for f in /home/metamax/Vincent/CS202_dRep_dereplicated_bins/*.fasta; do run_antismash $f /home/metamax/Vincent/CS202_dRep_dereplicated_bins_antismash_output/ -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs; done
```

#### CS203
```shell
$ for f in /home/metamax/Vincent/CS203_dRep_dereplicated_bins/*.fasta; do run_antismash $f /home/metamax/Vincent/CS203_dRep_dereplicated_bins_antismash_output/ -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs; done
```

#### CS204
```shell
$ for f in /home/metamax/Vincent/CS204_dRep_dereplicated_bins/*.fasta; do run_antismash $f /home/metamax/Vincent/CS204_dRep_dereplicated_bins_antismash_output/ -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs; done
```

#### CS211
```shell
$ for f in /home/metamax/Vincent/CS211_dRep_dereplicated_bins/*.fasta; do run_antismash $f /home/metamax/Vincent/CS211_dRep_dereplicated_bins_antismash_output/ -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs; done
```

### lenght-filtered (>5kb) assemblies
- antiSMASH version 4.1.0 (conda) on raapoi

#### CS200
```shell
$ bash ~/fasta_len_filter.sh ./CS200_taxonomy/contigs.fasta ./CS200_contigs_len_5000_filtered.fasta 5000
$ sbatch antiSMASH_CS200_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_CS200.out
#SBATCH -e /nfs/home/nowakvi/anti_CS200.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_CS200 /nfs/scratch/nowakvi/CS200_contigs_len_5000_filtered.fasta
""
```
- 16715 contigs

#### CS202
```shell
$ bash ~/fasta_len_filter.sh ./CS202_taxonomy/contigs.fasta ./antiSMASH_CS202/contigs_len_5000_filtered.fasta 5000
$ sbatch antiSMASH_CS202_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_CS202.out
#SBATCH -e /nfs/home/nowakvi/anti_CS202.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_CS202 /nfs/scratch/nowakvi/CS202_contigs_len_5000_filtered.fasta
""
```
- 13069 contigs

#### CS203
```shell
$ bash ~/fasta_len_filter.sh ./CS203_taxonomy/contigs.fasta ./CS203_contigs_len_5000_filtered.fasta 5000
$ sbatch antiSMASH_CS203_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_CS203.out
#SBATCH -e /nfs/home/nowakvi/anti_CS203.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_CS203 /nfs/scratch/nowakvi/CS203_contigs_len_5000_filtered.fasta
""
```
- 17794 contigs

#### CS204
```shell
$ bash ~/fasta_len_filter.sh ./CS204_taxonomy/contigs.fasta ./CS204_contigs_len_5000_filtered.fasta 5000
$ sbatch antiSMASH_CS204_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_CS204.out
#SBATCH -e /nfs/home/nowakvi/anti_CS204.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_CS204 /nfs/scratch/nowakvi/CS204_contigs_len_5000_filtered.fasta
""
```
- 17737 contigs

#### CS211
```shell
$ bash ~/fasta_len_filter.sh ./CS211_taxonomy/contigs.fasta ./CS211_contigs_len_5000_filtered.fasta 5000
$ sbatch antiSMASH_CS211_Tru_adap_meta_SPAdes.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/anti_CS211.out
#SBATCH -e /nfs/home/nowakvi/anti_CS211.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate antismash4.2.0
antismash -c 12 --full-hmmer --clusterblast --subclusterblast --knownclusterblast --smcogs --outputfolder /nfs/scratch/nowakvi/antiSMASH_CS211 /nfs/scratch/nowakvi/CS211_contigs_len_5000_filtered.fasta
""
```
- 20253 contigs


### Summary BGCs per secondary metabolite group as listed in geneclusters.txt file from antiSMASH output

#### CS200
```shell
$ grep "c*_NODE_*" geneclusters.txt | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c
   2 arylpolyene
  49 bacteriocin
   1 bacteriocin-lantipeptide
   3 ectoine
   4 lantipeptide
   3 lassopeptide
   1 nrps
  34 other
   3 phosphonate
  70 t1pks
   3 t2pks
   7 t3pks
 109 terpene
```
#### CS202
```shell
$ grep "c*_NODE_*" geneclusters.txt | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c
      1 arylpolyene
     39 bacteriocin
      3 lantipeptide
      2 lassopeptide
      1 microcin
      1 nrps
     21 other
      3 phosphonate
     45 t1pks
      2 t2pks
      5 t3pks
     70 terpene
```
#### CS203
```shell
$ grep "c*_NODE_*" geneclusters.txt | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c
      1 arylpolyene
     26 bacteriocin
      2 bacteriocin-lantipeptide
      1 lantipeptide
      6 lassopeptide
      1 nrps
      4 nucleoside
      1 oligosaccharide
     22 other
      2 phosphonate
      1 proteusin
     64 t1pks
      2 t2pks
      6 t3pks
     74 terpene
      1 thiopeptide
      1 transatpks
```
#### CS204
```shell
$ grep "c*_NODE_*" geneclusters.txt | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c
      1 arylpolyene
     39 bacteriocin
      2 ectoine
      2 lantipeptide
      6 lassopeptide
      1 nrps
      1 nucleoside
     23 other
      3 phosphonate
      1 proteusin
     64 t1pks
      1 t2pks
      5 t3pks
     59 terpene
```
#### CS211
```shell
$ grep "c*_NODE_*" geneclusters.txt | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c
      9 arylpolyene
     51 bacteriocin
      2 bacteriocin-proteusin
      3 ectoine
      1 lantipeptide
      1 lassopeptide
      2 nrps
     25 other
      2 phosphonate
     79 t1pks
      1 t2pks
      8 t3pks
     91 terpene
      1 thiopeptide-bacteriocin
      1 transatpks-t1pks
```

### Summary of BGCs per taxonomic group

#### CS200
```shell
$ for i in */geneclusters.txt; do echo $i | awk -F "/" '{print $1}'; grep "c*_NODE_*" $i | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c; done
```
- copied output from shell into emacs, then excel file and reformatted manually
- added .fasta to bin names
- on macbook using R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> bgcs <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS200_BGCs_per_bin.csv", header = TRUE, sep = ",")
> bin_tax <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS200_dRep_Chdb.csv", header = TRUE, sep = ",")
# checked head
> table(bgcs$X %in% bin_tax$Bin.Id)
TRUE 
  76 
> bgcs$marker_lineage <- bin_tax$Marker.lineage[match(bgcs$X, bin_tax$Bin.Id)]
# checked head and tail
> write.table(bgcs, "~/Documents/Sequencing/5_sponges_2018/CS200_BGCs_per_bin_final.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
```

#### CS202
```shell
$ for i in */geneclusters.txt; do echo $i | awk -F "/" '{print $1}'; grep "c*_NODE_*" $i | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c; done
```
- copied output from shell into emacs, then excel file and reformatted manually
- added .fasta to bin names
- on macbook using R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> bgcs <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS202_BGCs_per_bin.csv", header = TRUE, sep = ",")
> bin_tax <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS202_dRep_Chdb.csv", header = TRUE, sep = ",")
- checked head
> table(bgcs$X %in% bin_tax$Bin.Id)
TRUE 
  55
> bgcs$marker_lineage <- bin_tax$Marker.lineage[match(bgcs$X, bin_tax$Bin.Id)]
# checked head and tail
> write.table(bgcs, "~/Documents/Sequencing/5_sponges_2018/CS202_BGCs_per_bin_final.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
```

#### CS203
```shell
$ for i in */geneclusters.txt; do echo $i | awk -F "/" '{print $1}'; grep "c*_NODE_*" $i | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c; done
```
- copied output from shell into emacs, then excel file and reformatted manually
- added .fasta to bin names
- on macbook using R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> bgcs <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS203_BGCs_per_bin.csv", header = TRUE, sep = ",")
> bin_tax <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS203_dRep_Chdb.csv", header = TRUE, sep = ",")
# checked head
> table(bgcs$X %in% bin_tax$Bin.Id)
TRUE 
  52
> bgcs$marker_lineage <- bin_tax$Marker.lineage[match(bgcs$X, bin_tax$Bin.Id)]
# checked head and tail
> write.table(bgcs, "~/Documents/Sequencing/5_sponges_2018/CS203_BGCs_per_bin_final.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
```

#### CS204
```shell
$ for i in */geneclusters.txt; do echo $i | awk -F "/" '{print $1}'; grep "c*_NODE_*" $i | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c; done
```
- copied output from shell into emacs, then excel file and reformatted manually
- added .fasta to bin names
- on macbook using R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> bgcs <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS204_BGCs_per_bin.csv", header = TRUE, sep = ",")
> bin_tax <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS204_dRep_Chdb.csv", header = TRUE, sep = ",")
# checked head
> table(bgcs$X %in% bin_tax$Bin.Id)
TRUE 
  50
> bgcs$marker_lineage <- bin_tax$Marker.lineage[match(bgcs$X, bin_tax$Bin.Id)]
# checked head and tail
> write.table(bgcs, "~/Documents/Sequencing/5_sponges_2018/CS204_BGCs_per_bin_final.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
```

#### CS211
```shell
$ for i in */geneclusters.txt; do echo $i | awk -F "/" '{print $1}'; grep "c*_NODE_*" $i | awk -v FS='\t' -v OFS='\t' '{print $2,$3}' | cut -f 2 | sort | uniq -c; done
```
- copied output from shell into emacs, then excel file and reformatted manually
- added .fasta to bin names
- on macbook using R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> bgcs <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS211_BGCs_per_bin.csv", header = TRUE, sep = ",")
> bin_tax <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS211_dRep_Chdb.csv", header = TRUE, sep = ",")
# checked head
> table(bgcs$X %in% bin_tax$Bin.Id)
TRUE 
  48
> bgcs$marker_lineage <- bin_tax$Marker.lineage[match(bgcs$X, bin_tax$Bin.Id)]
# checked head and tail
> write.table(bgcs, "~/Documents/Sequencing/5_sponges_2018/CS211_BGCs_per_bin_final.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
```
- Note that some of the BGCs identified in dRep dereplicated bins were from contigs <5kb, thus enumerated below are the numbers of BGCs identified from dRep dereplicated bins that are >=5kb for each sponge
```shell
#CS200
$ for i in */geneclusters.txt; do grep "c*_NODE_*" $i | awk -v FS='\t' '{print $2}' | awk -v FS='_' -v OFS='\n' '{print $4}'; done | awk '$1>=5000{c++} END{print c+0}'
226
#CS202
$ for i in */geneclusters.txt; do grep "c*_NODE_*" $i | awk -v FS='\t' '{print $2}' | awk -v FS='_' -v OFS='\n' '{print $4}'; done | awk '$1>=5000{c++} END{print c+0}'
141
#CS203
$ for i in */geneclusters.txt; do grep "c*_NODE_*" $i | awk -v FS='\t' '{print $2}' | awk -v FS='_' -v OFS='\n' '{print $4}'; done | awk '$1>=5000{c++} END{print c+0}'
142
#CS204
$ for i in */geneclusters.txt; do grep "c*_NODE_*" $i | awk -v FS='\t' '{print $2}' | awk -v FS='_' -v OFS='\n' '{print $4}'; done | awk '$1>=5000{c++} END{print c+0}'
136
#CS211
$ for i in */geneclusters.txt; do grep "c*_NODE_*" $i | awk -v FS='\t' '{print $2}' | awk -v FS='_' -v OFS='\n' '{print $4}'; done | awk '$1>=5000{c++} END{print c+0}'
142
```

### Summary plot of BGCs per taxonomic group per secondary metabolite class for all six sponges
- copied data from copied data from Zamp_150_BGCs_per_taxon and added it to "Summary of BGCs per taxonomic group" established above, then reformatted it manually to contain 4 columns with sponge, marker_lineage, compound_class and count
- checked total number of clusters was what was expected and number of clusters per sponges was what was expected
- on Desktop running Ubuntu 18.04.2 LTS (GNU/Linux 4.15.0-47-generic x86_64) using R version 3.4.4 (2018-03-15) -- "Someone to Lean On"
```{r}
> df2 <- read.delim("~/Downloads/6_sponges_BGCs_per_taxon_summary_reformatted_1.csv", header = TRUE, sep = ",")
> ggplot(df2, aes(marker_lineage, cluster_count)) +  geom_bar(aes(fill = marker_lineage), stat = "identity") + theme(axis.text.x = element_blank(), axis.text.y = element_text(size=5), legend.key.size = unit(0.25, "cm"), legend.text = element_text(size=5)) + facet_grid(compound_class ~ Sponge, scales = "free_y") + theme(strip.text.y = element_text(size = 5, angle = 360)) + labs(x="Marker lineage", y="# BGCs", cex.lab=0.01)
Warning message:
Removed 868 rows containing missing values (position_stack). 
> tonga <- ggplot(df2, aes(marker_lineage, cluster_count)) +  geom_bar(aes(fill = marker_lineage), stat = "identity") + theme(axis.text.x = element_blank(), axis.text.y = element_text(size=5), legend.key.size = unit(0.25, "cm"), legend.text = element_text(size=5)) + facet_grid(compound_class ~ Sponge, scales = "free_y") + theme(strip.text.y = element_text(size = 5, angle = 360)) + labs(x="Marker lineage", y="# BGCs", cex.lab=0.01)
>  pdf(file = "Documents/6_sponges_BGC_per_taxon_plot_free_y.pdf")
Error in pdf(file = "Documents/6_sponges_BGC_per_taxon_plot_free_y.pdf") : 
  cannot open file 'Documents/6_sponges_BGC_per_taxon_plot_free_y.pdf'
>  pdf(file = "~/Documents/6_sponges_BGC_per_taxon_plot_free_y.pdf")
> plot(tonga)
Warning message:
Removed 868 rows containing missing values (position_stack). 
> dev.off()
null device 
          1 
```


## BiG-SCAPE of all 6 sponges
```shell
$ sbatch sbatch_scripts/BiG-SCAPE_all_sponges.sh
""
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=48G
#SBATCH --partition=parallel
#SBATCH --time=3-12:00
#SBATCH -o /nfs/home/nowakvi/BiG-SCAPE_all_sponges_glocal.out
#SBATCH -e /nfs/home/nowakvi/BiG-SCAPE_all_sponges_glocal.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=vincent.nowak@vuw.ac.nz

source activate bigscape
python ~/BiG-SCAPE/bigscape.py -c 24 --mode glocal --mibig --cutoffs 0.3 0.5 0.7 0.9 -i /nfs/scratch/nowakvi/all_sponges_antiSMASH_gbks -o /nfs/scratch/nowakvi/all_sponges_antiSMASH_gbks_glocal_cutoffs_MiBIG
source deactivate
""
```
- finished successfully, i.e. slurm exit code = 0, and produced all the outputs but did throw several errors that arbitray clusters were returned as well as an error that index is out of range in one analysis was out of range (likely the 0.7 cutoff terepne)
- includes MiBIG BGCs in html output as BGC's with blue circles around them



## Coverage over %GC blobplots per sponge and as summary plot
- script (calc.gc.pl) that calculates gc content of each contig (from Albersten et. al 2013)
- git://github.com/MadsAlbertsen/multi-metagenome.git

### CS200
```shell
$ cp contigs.fasta assembly.fa
$ perl ~/multi-metagenome/R.data.generation/calc.gc.pl -i assembly.fa -o assembly.gc.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "coverage"} {print $6}' > coverage_column.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "length"} {print $4}' > assembly_length.tab
$ paste -d '\t' assembly.gc.tab coverage_column.tab > assembly_copy.gc.coverage.tab
$ paste -d '\t' assembly_copy.gc.coverage.tab assembly_length.tab > assembly.gc.coverage.length.tab
# checked head and tail match
# .fasta below are the fasta files of the individual bins
$ grep "^>" *.fasta | sed 's/:>/\t/' | awk -F'_' 'BEGIN {print "bin""\t""contig"} {print $0}' > contigs_per_bin.tsv
```
- plotting data with ggplot2 on MacBook (macOS  10.14.2) with R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> gc_coverage <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS200_plot_data/assembly.gc.coverage.length.tab", header=TRUE, sep="\t")
> contigs_per_bin <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS200_plot_data/contigs_per_bin.tsv", header=TRUE, sep="\t")
> bin_taxonomy <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS200_plot_data/results.tsv", header=TRUE, sep="\t")
> table(gc_coverage$contig %in% contigs_per_bin$contig)
 FALSE   TRUE 
488915  20397
> gc_coverage$bin <- contigs_per_bin$bin[match(gc_coverage$contig, contigs_per_bin$contig)]
> table(unique(gc_coverage$bin) %in% contigs_per_bin$bin)
FALSE  TRUE 
    1    76
# Matches number of fastas in dereplicated_genomes; FALSE is NA for contigs without bins
> table(gc_coverage$bin %in% bin_taxonomy$Bin)
 FALSE   TRUE 
488915  20397 
> gc_coverage$marker_lineage <- bin_taxonomy$Marker.lineage[match(gc_coverage$bin, bin_taxonomy$Bin.Id)]
# writing out table
> write.table(gc_coverage, file="/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS200_plot_data/CS200_plot_final_table.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
# plotting data
> ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 8000)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
# writing out plot file
> CS200 <- ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 8000)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
> png(file = "/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS200_plot_data/CS200_plot.png")
> plot(CS200)
> dev.off()
null device 
          1
```

### CS202
```shell
$ cp contigs.fasta assembly.fa
$ perl ~/multi-metagenome/R.data.generation/calc.gc.pl -i assembly.fa -o assembly.gc.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "coverage"} {print $6}' > coverage_column.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "length"} {print $4}' > assembly_length.tab
# checked wc -l all the same
$ paste -d '\t' assembly.gc.tab coverage_column.tab > assembly_copy.gc.coverage.tab
$ paste -d '\t' assembly_copy.gc.coverage.tab assembly_length.tab > assembly.gc.coverage.length.tab
# checked head and tail
# .fasta below are the fasta files of the individual bins
$ grep "^>" *.fasta | sed 's/:>/\t/' | awk -F'_' 'BEGIN {print "bin""\t""contig"} {print $0}' > contigs_per_bin.tsv
```
- plotting data with ggplot2 on MacBook (macOS  10.14.2) with R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> gc_coverage <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS202_plot_data/assembly.gc.coverage.length.tab", header=TRUE, sep="\t")
> contigs_per_bin <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS202_plot_data/contigs_per_bin.tsv", header=TRUE, sep="\t")
> bin_taxonomy <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS202_plot_data/results.tsv", header=TRUE, sep="\t")
> table(gc_coverage$contig %in% contigs_per_bin$contig)
 FALSE   TRUE 
839406  20473 
> gc_coverage$bin <- contigs_per_bin$bin[match(gc_coverage$contig, contigs_per_bin$contig)]
> table(unique(gc_coverage$bin) %in% contigs_per_bin$bin)
FALSE  TRUE 
    1    55
> table(gc_coverage$bin %in% bin_taxonomy$Bin)
 FALSE   TRUE 
839406  20473 
> gc_coverage$marker_lineage <- bin_taxonomy$Marker.lineage[match(gc_coverage$bin, bin_taxonomy$Bin.Id)]
# checked head and tail
# writing out table
> write.table(gc_coverage, file="/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS202_plot_data/CS202_plot_final_table.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
# plotting data
> ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 1100)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
Warning message:
Removed 1 rows containing missing values (geom_point). 
# one point not plotted found out to be this one
> gc_coverage[gc_coverage$coverage >= 81203, ]
                                        contig    gc coverage length  bin  marker_lineage
858491 NODE_858491_length_129_cov_81203.500000 49.61  81203.5    129 <NA> <NA>
> png(file = "/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS202_plot_data/CS202_plot.png")
> plot(CS202)
Warning message:
Removed 1 rows containing missing values (geom_point). 
> dev.off()
null device 
          1
```

#### CS203
```shell
$ cp contigs.fasta assembly.fa
$ perl ~/multi-metagenome/R.data.generation/calc.gc.pl -i assembly.fa -o assembly.gc.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "coverage"} {print $6}' > coverage_column.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "length"} {print $4}' > assembly_length.tab
# checked wc -l all the same
$ paste -d '\t' assembly.gc.tab coverage_column.tab > assembly_copy.gc.coverage.tab
$ paste -d '\t' assembly_copy.gc.coverage.tab assembly_length.tab > assembly.gc.coverage.length.tab
# checked wc -l, head and tail
# .fasta below are the fasta files of the individual bins
$ grep "^>" *.fasta | sed 's/:>/\t/' | awk -F'_' 'BEGIN {print "bin""\t""contig"} {print $0}' > contigs_per_bin.tsv
```
- plotting data with ggplot2 on MacBook (macOS  10.14.2) with R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> gc_coverage <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS203_plot_data/assembly.gc.coverage.length.tab", header=TRUE, sep="\t")
> contigs_per_bin <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS203_plot_data/contigs_per_bin.tsv", header=TRUE, sep="\t")
> bin_taxonomy <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS203_plot_data/results.tsv", header=TRUE, sep="\t")
> table(gc_coverage$contig %in% contigs_per_bin$contig)
 FALSE   TRUE 
978112  20408 
> gc_coverage$bin <- contigs_per_bin$bin[match(gc_coverage$contig, contigs_per_bin$contig)]
> table(unique(gc_coverage$bin) %in% contigs_per_bin$bin)
FALSE  TRUE 
    1    52 
> table(gc_coverage$bin %in% bin_taxonomy$Bin)
 FALSE   TRUE 
978112  20408 
> gc_coverage$marker_lineage <- bin_taxonomy$Marker.lineage[match(gc_coverage$bin, bin_taxonomy$Bin.Id)]
# checked head and tail
# writing out table
> write.table(gc_coverage, file="/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS203_plot_data/CS203_plot_final_table.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
- plotting data
> ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 100)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
> CS203 <- ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 100)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
> png(file = "/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS203_plot_data/CS203_plot.png")
> plot(CS203)
> dev.off()
null device 
          1
```

#### CS204
```shell
$ cp contigs.fasta assembly.fa
$ perl ~/multi-metagenome/R.data.generation/calc.gc.pl -i assembly.fa -o assembly.gc.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "coverage"} {print $6}' > coverage_column.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "length"} {print $4}' > assembly_length.tab
# checked wc -l all the same
$ paste -d '\t' assembly.gc.tab coverage_column.tab > assembly_copy.gc.coverage.tab
$ paste -d '\t' assembly_copy.gc.coverage.tab assembly_length.tab > assembly.gc.coverage.length.tab
# checked head and tail
$ grep "^>" *.fasta | sed 's/:>/\t/' | awk -F'_' 'BEGIN {print "bin""\t""contig"} {print $0}' > contigs_per_bin.tsv
```
- plotting data with ggplot2 on MacBook (macOS  10.14.2) with R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> gc_coverage <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS204_plot_data/assembly.gc.coverage.length.tab", header=TRUE, sep="\t")
> contigs_per_bin <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS204_plot_data/contigs_per_bin.tsv", header=TRUE, sep="\t")
> bin_taxonomy <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS204_plot_data/results.tsv", header=TRUE, sep="\t")
> table(gc_coverage$contig %in% contigs_per_bin$contig)
 FALSE   TRUE 
843261  18467
> gc_coverage$bin <- contigs_per_bin$bin[match(gc_coverage$contig, contigs_per_bin$contig)]
> table(unique(gc_coverage$bin) %in% contigs_per_bin$bin)
FALSE  TRUE 
    1    50
# Matches number of fastas in dereplicated_genomes; FALSE is NA for contigs without bins
> table(gc_coverage$bin %in% bin_taxonomy$Bin)
 FALSE   TRUE 
843261  18467 
> gc_coverage$marker_lineage <- bin_taxonomy$Marker.lineage[match(gc_coverage$bin, bin_taxonomy$Bin.Id)]
# checked head and tail
# writing out table
> write.table(gc_coverage, file="/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS204_plot_data/CS204_plot_final_table.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
# plotting data
> ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 100)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
# one did not plot, was found out to be this outlier
> gc_coverage[gc_coverage$coverage >= 52000, ]
                                        contig  gc coverage length  bin	marker_lineage
860180 NODE_860180_length_128_cov_52820.000000 100    52820    128 <NA>	<NA>
> CS204 <- ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 100)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
> png(file = "/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS204_plot_data/CS204_plot.png")
> plot(CS204)
Warning message:
Removed 1 rows containing missing values (geom_point). 
> dev.off()
quartz 
     2
```

#### CS211
```shell
$ cp contigs.fasta assembly.fa
$ perl ~/multi-metagenome/R.data.generation/calc.gc.pl -i assembly.fa -o assembly.gc.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "coverage"} {print $6}' > coverage_column.tab
$ grep "^>" assembly.fa | awk -F'_' 'BEGIN {print "length"} {print $4}' > assembly_length.tab
# checked wc -l all the same
$ paste -d '\t' assembly.gc.tab coverage_column.tab > assembly_copy.gc.coverage.tab
$ paste -d '\t' assembly_copy.gc.coverage.tab assembly_length.tab > assembly.gc.coverage.length.tab
# checked wc -l, head and tail
$ grep "^>" *.fasta | sed 's/:>/\t/' | awk -F'_' 'BEGIN {print "bin""\t""contig"} {print $0}' > contigs_per_bin.tsv
```
- plotting data with ggplot2 on MacBook (macOS  10.14.2) with R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
```{r}
> gc_coverage <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS211_plot_data/assembly.gc.coverage.length.tab", header=TRUE, sep="\t")
> contigs_per_bin <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS211_plot_data/contigs_per_bin.tsv", header=TRUE, sep="\t")
> bin_taxonomy <- read.delim("~/Documents/Sequencing/5_sponges_2018/CS211_plot_data/results.tsv", header=TRUE, sep="\t")
> table(gc_coverage$contig %in% contigs_per_bin$contig)
  FALSE    TRUE 
1078187   16017
> gc_coverage$bin <- contigs_per_bin$bin[match(gc_coverage$contig, contigs_per_bin$contig)]
> table(unique(gc_coverage$bin) %in% contigs_per_bin$bin)
FALSE  TRUE 
    1    48
# Matches number of fastas in dereplicated_genomes; FALSE is NA for contigs without bins
> table(gc_coverage$bin %in% bin_taxonomy$Bin)
  FALSE    TRUE 
1078187   16017 
> gc_coverage$marker_lineage <- bin_taxonomy$Marker.lineage[match(gc_coverage$bin, bin_taxonomy$Bin.Id)]
# checked head and tail
# writing out table
> write.table(gc_coverage, file="/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS211_plot_data/CS211_plot_final_table.tsv", quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)
# plotting data
> ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 1000)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
> CS211 <- ggplot(gc_coverage[!is.na(gc_coverage$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10(limits = c(0.1, 1000)) + theme_bw() + theme(legend.position="right", legend.key.size = unit(0.25, "cm")) + xlab("% GC") + ylab("log10(coverage)") + scale_size_area(name = "Contig length", max_size = 20) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3, shape = 19)))
> png(file = "/Users/vincentn/Documents/Sequencing/5_sponges_2018/CS211_plot_data/CS211_plot.png")
> plot(CS211)
> dev.off()
null device 
          1
```

#### 6_sponges summary plot
```{r}
> CS200 <- read.delim("~/Documents/CS200_plot_final_table.tsv", header = TRUE)
> CS202 <- read.delim("~/Documents/CS202_plot_final_table.tsv", header = TRUE)
> CS203 <- read.delim("~/Documents/CS203_plot_final_table.tsv", header = TRUE)
> CS204 <- read.delim("~/Documents/CS204_plot_final_table.tsv", header = TRUE)
> CS211 <- read.delim("~/Documents/CS211_plot_final_table.tsv", header = TRUE)
> CS783 <- read.delim("~/Documents/Zamp_150_plus_Nano_dRep_dereplicated_bins_plot_final_table.tsv", header = TRUE)
# checked head and tail
> CS200$sponges <- "CS200"
> CS202$sponges <- "CS202"
> CS203$sponges <- "CS203"
> CS204$sponges <- "CS204"
> CS211$sponges <- "CS211"
> CS783$sponges <- "CS783"
# checked head and tail
> nrow(rbind(CS200, CS202, CS203, CS204, CS211, CS783))
[1] 4870176
> nrow(CS200)
[1] 509312
> nrow(CS202)
[1] 859879
> nrow(CS203)
[1] 998520
> nrow(CS204)
[1] 861728
> nrow(CS211)
[1] 1094204
> nrow(CS783)
[1] 546533
> nrow(CS200) + nrow(CS202)
[1] 1369191
> nrow(CS200) + nrow(CS202) + nrow(CS203) + nrow(CS204) + nrow(CS211) + nrow(CS783)
[1] 4870176
> all_sponges <- rbind(CS200, CS202, CS203, CS204, CS211, CS783)
> scaled_plot2 <- ggplot(all_sponges[!is.na(all_sponges$bin), ], aes(x = gc, y = coverage, color = marker_lineage, size = length)) + geom_point(alpha = 0.25, shape = 21, stroke = (0.8)) + scale_y_log10() + theme_bw() + theme(legend.title.align = 0.5, legend.position = "bottom", legend.text = element_text(size=3.5), legend.key.size = unit(0.01, "cm"), legend.title = element_text(size=6), legend.spacing = unit(0.0, "cm"), axis.text.x = element_text(size=4), axis.text.y = element_text(size=4), axis.title.x = element_text(size=6), axis.title.y = element_text(size=6)) +  labs(x="% GC", y="log10(coverage)") + scale_size_area(name = "contig length", max_size = 6.25) + guides(colour = guide_legend(override.aes = list(alpha = 1, size = 1, shape = 19), title.position="top"), size = guide_legend(title.position="top")) + facet_wrap(~ sponges, ncol=3)
> pdf(file = "~/Documents/6_sponges_scaled_blobplot4.pdf")
> plot(scaled_plot2)
^[dev.off()
X11cairo 
       2
```

### Summary of the number of dereplicated bins per marker lineage

#### CS200
```shell
$ cut -f 6,5 CS200_plot_final_table.tsv | sort -su | cut -f 2 | sort | uniq -c | column -t
1   NA
1   c__Alphaproteobacteria  (UID3305)
3   c__Gammaproteobacteria  (UID4267)
6   c__Gammaproteobacteria  (UID4443)
1   k__Archaea              (UID2)
25  k__Bacteria             (UID1452)
6   k__Bacteria             (UID1453)
2   k__Bacteria             (UID203)
15  k__Bacteria             (UID2495)
1   k__Bacteria             (UID2565)
1   k__Bacteria             (UID2570)
1   k__Bacteria             (UID2982)
14  k__Bacteria             (UID3187)
1   marker_lineage
```
#### CS202
```shell
$ cut -f 6,5 CS202_plot_final_table.tsv | sort -su | cut -f 2 | sort | uniq -c
   1 NA
   1 c__Alphaproteobacteria (UID3305)
   1 c__Deltaproteobacteria (UID3216)
   3 c__Gammaproteobacteria (UID4267)
   5 c__Gammaproteobacteria (UID4443)
   1 k__Archaea (UID2)
  12 k__Bacteria (UID1452)
   6 k__Bacteria (UID1453)
   4 k__Bacteria (UID203)
  10 k__Bacteria (UID2495)
   1 k__Bacteria (UID2570)
   8 k__Bacteria (UID3187)
   1 marker_lineage
   3 o__Rhodospirillales (UID3754)
```
#### CS203
```shell
$ cut -f 6,5 CS203_plot_final_table.tsv | sort -su | cut -f 2 | sort | uniq -c
   1 NA
   1 c__Gammaproteobacteria (UID4201)
   1 c__Gammaproteobacteria (UID4267)
   2 c__Gammaproteobacteria (UID4443)
   1 k__Archaea (UID2)
  13 k__Bacteria (UID1452)
   7 k__Bacteria (UID1453)
   2 k__Bacteria (UID203)
   1 k__Bacteria (UID2142)
  13 k__Bacteria (UID2495)
   1 k__Bacteria (UID2566)
   1 k__Bacteria (UID2570)
   8 k__Bacteria (UID3187)
   1 marker_lineage
   1 o__Rhodospirillales (UID3754)
```
#### CS204
```shell
$ cut -f 6,5 CS204_plot_final_table.tsv | sort -su | cut -f 2 | sort | uniq -c
   1 NA
   1 c__Alphaproteobacteria (UID3305)
   1 c__Gammaproteobacteria (UID4274)
   4 c__Gammaproteobacteria (UID4443)
   2 k__Archaea (UID2)
  12 k__Bacteria (UID1452)
   5 k__Bacteria (UID1453)
   2 k__Bacteria (UID203)
  13 k__Bacteria (UID2495)
   1 k__Bacteria (UID2570)
   8 k__Bacteria (UID3187)
   1 marker_lineage
   1 o__Rhodospirillales (UID3754)
```
#### CS211
```shell
$ cut -f 6,5 CS211_plot_final_table.tsv | sort -su | cut -f 2 | sort | uniq -c
   1 NA
   1 c__Alphaproteobacteria (UID3305)
   1 c__Gammaproteobacteria (UID4202)
   3 c__Gammaproteobacteria (UID4443)
   2 k__Archaea (UID2)
  16 k__Bacteria (UID1452)
   2 k__Bacteria (UID1453)
   1 k__Bacteria (UID203)
   1 k__Bacteria (UID2142)
   9 k__Bacteria (UID2495)
  10 k__Bacteria (UID3187)
   1 marker_lineage
   2 o__Rhodospirillales (UID3754
```


## Sponge_taxonomy
- used this kind of command to visualize reuslts
```shell
$ cut -d ";" -f3,5,9,10,14,17-22 CS202_arb_silva_resultlist_590203.csv | column -s ";" -t | head -n 6
```

### CS200
```shell
$ barrnap --threads 12 --kingdom euk --outseq CS200_Tru_adap_meta_SPAdes_barrnap_ouseqs.fasta contigs.fasta
```
- identified 401 sequences
- SILVA ACT online tool with default settings for "basic alignment parameters" and "search and classify"

### CS202
```shell
$ barrnap --threads 12 --kingdom euk --outseq CS202_Tru_adap_meta_SPAdes_barrnap_ouseqs.fasta contigs.fasta
```
- identified 371 sequences

### CS203
```shell
$ barrnap --threads 12 --kingdom euk --outseq CS203_Tru_adap_meta_SPAdes_barrnap_ouseqs.fasta contigs.fasta
```
- identified 462 sequences

###CS204
```shell
$ barrnap --threads 12 --kingdom euk --outseq CS204_Tru_adap_meta_SPAdes_barrnap_outseqs.fasta contigs.fasta
```
- identified 454 sequences

###CS211
```
$ barrnap --threads 12 --kingdom euk --outseq CS211_Tru_adap_meta_SPAdes_barrnap_outseqs.fasta contigs.fasta
```
- identified 417 sequences



## Aligning 18S rRNA sequences of the 6 Tongan sponges
- Example of workflow applied to extract 18S rRNA sequence identifier
```shell
$ awk -F';' '{print $3, $9, $10, $14, $17, $18, $19, $20}' CS204_arb-silva_resultlist_590823.csv | sort -s -k 2 | column -t
```
- visually identified highest identity alignment from Porifera phylum
```shell
$ samtools faidx CS204_Tru_adap_meta_SPAdes_barrnap_outseqs.fasta "18S_rRNA::NODE_8303_length_8368_cov_1173.394370:1674-3472(+)" > CS204_Tru_adap_meta_SPAdes_barrnap_sequence_identifier.fasta
[W::hts_parse_decimal] Ignoring unknown characters after 3472[(+)]
[faidx] Truncated sequence: 18S_rRNA::NODE_8303_length_8368_cov_1173.394370:1674-3472(+)
$ awk -F';' '{print $3, $9, $10, $14, $17, $18, $19, $20}' CS202_arb_silva_resultlist_590203.csv | sort -s -k 2 | column -t
$ samtools faidx CS202_Tru_adap_meta_SPAdes_barrnap_ouseqs.fasta
$ samtools faidx CS202_Tru_adap_meta_SPAdes_barrnap_ouseqs.fasta "18S_rRNA::NODE_371783_length_534_cov_1.523342:1-534(-)" > CS202_Tru_adap_meta_SPAdes_barrnap_sequence_identifier.fasta
[W::hts_parse_decimal] Ignoring unknown characters after 534[(-)]
[faidx] Truncated sequence: 18S_rRNA::NODE_371783_length_534_cov_1.523342:1-534(-)
```
- Example of the alignment output
```shell
$ bbmap.sh -Xmx3500m ref=CS204_Tru_adap_meta_SPAdes_barrnap_sequence_identifier.fasta in=CS203_Tru_adap_meta_SPAdes_barrnap_sequence_identifier.fasta out=CS203_to_CS204.sam
   ------------------   Results   ------------------   

Genome:                	1
Key Length:            	13
Max Indel:             	16000
Minimum Score Ratio:  	0.56
Mapping Mode:         	normal
Reads Used:           	3	(1281 bases)

Mapping:          	1.007 seconds.
Reads/sec:       	2.98
kBases/sec:      	1.27


Read 1 data:      	pct reads	num reads 	pct bases	   num bases

mapped:          	100.0000% 	        3 	100.0000% 	        1281
unambiguous:     	100.0000% 	        3 	100.0000% 	        1281
ambiguous:       	  0.0000% 	        0 	  0.0000% 	           0
low-Q discards:  	  0.0000% 	        0 	  0.0000% 	           0

perfect best site:	  0.0000% 	        0 	  0.0000% 	           0
semiperfect site:	  0.0000% 	        0 	  0.0000% 	           0

Match Rate:      	      NA 	       NA 	 90.0234% 	        1155
Error Rate:      	100.0000% 	        3 	  9.9766% 	         128
Sub Rate:        	100.0000% 	        3 	  9.5090% 	         122
Del Rate:        	 66.6667% 	        2 	  0.1559% 	           2
Ins Rate:        	 66.6667% 	        2 	  0.3118% 	           4
N Rate:          	  0.0000% 	        0 	  0.0000% 	           0

Total time:     	10.588 seconds.
```

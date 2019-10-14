#This will create a fasta file with all of the hsp70 reference genes

for filename in hsp70gene_*.fasta
do
cat $filename >> hsp70total.fasta
done


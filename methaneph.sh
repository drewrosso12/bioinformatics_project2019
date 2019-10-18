# usage bash methaneph.sh './ref_sequences/mcrAgene_*.fasta' './proteomes/proteome_*.fasta' './ref_sequences/hsp70gene_*.fasta'

#concatenates all of the mcrA reference sequences into one document
cat $1 >> mcrA.refs
#concatenates all of the hsp70 reference genes into one document
cat $3 >> hsp70.refs 
#takes the refernce sequence .fasta file and uses muscle to align it
./muscle -in mcrA.refs -out mcrAalign.fasta
#takes the refernce sequence .fasta file for hsp70 and uses muscle to align it
./muscle -in hsp70.refs -out hsp70align.fasta
#takes the aligned reference sequences and uses hmmbuild to form hidden markov model of alignment
./hmmer/bin/hmmbuild buildmcrA.hmm mcrAalign.fasta
#takes the aligned reference sequences for hsp70 and uses hmmbuild to form hidden markov model of alignment
./hmmer/bin/hmmbuild buildhsp70.hmm hsp70align.fasta


#for each of the proteome samples (1-50) we use hmm search to see if it contains the mcrA gene and hsp70 gene
for files in $2
do
  	recordName=$(echo $files | sed 's/.fasta//g')
        ./hmmer/bin/hmmsearch buildmcrA.hmm $files >  $recordName"m".txt
	./hmmer/bin/hmmsearch buildhsp70.hmm $files > $recordName"h".txt

      proteome=$(echo $recordName | sed 's/.\/proteomes\///g')
     # create summary table collating results -- name of proteome, number mcrA genes (0,1,or2) and number hsp70 genes (0,1,2,3) 
      echo -n  $proteome " " >> summary.txt
mcrA=$(cat $recordName"m".txt | head -n 18 | egrep "coenzyme-B"| wc -l)

#After evaluating the hmmbuild files for hsp70 and the reference proteins, we determined only molecular chaperone DnaK have biologically significant E-values
hsp70=$(cat $recordName"h".txt | head -n 18 | egrep "DnaK"| wc -l)

echo -n  $mcrA " " >> summary.txt
echo $hsp70 >> summary.txt
done

#creates a summary table of each proteome, listed by order of decreasing number of hsp70 genes, and indicates how many mcrA genes and hsp70 genes 
echo "proteome_num num-mcrA num-hsp70" > sortedsummary.txt
cat summary.txt | sort -r -k 3,3 >> sortedsummary.txt

#creates a list of only those proteomes with an mcrA gene (1 or 2 copies) and at least one hsp70 gene -- listed in order to number of hsp70 gene copies (highest first)
cat sortedsummary.txt | egrep "((1|2)  [1-4])" |cut -d ' ' -f 1,1 >> namesofsuitableproteomes.txt

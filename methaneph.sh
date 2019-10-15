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
        ./hmmer/bin/hmmsearch buildmcrA.hmm $files | head -n 20 > $recordNamemmcrA.txt
	./hmmer/bin/hmmsearch buildhsp70.hmm $files | head -n 15 > $recordNamehsp70.txt

       #proteome=$(echo $recordName | sed 's/.\/proteomes\///g')
        #create summary table collating results -- if there is an mcrA gene then it will give the coenzyme name -- if not it indicates there were no hits for that proteome
       # echo -n  $proteome " "
       # cat $recordName.txt | egrep -o -m 1 "(coenzyme-B sulfoethylthiotransferase subunit alpha |\[No hits detected that satisfy reporting thresholds\])"
       # echo -n  $proteome " " >> summary.txt
#cat $recordName.txt | egrep -o -m 1 "(coenzyme-B sulfoethylthiotransferase subunit alpha |\[No hits detected that satisfy reporting thresholds\])" >>summary.txt
done
#takes only those proteomes with mcrA gene and creates txt file with the name of associated proteome
#cat summary.txt | egrep "coenzyme-B sulfoethylthiotransferase subunit alpha" |cut -d ' ' -f 1,1 >> namesofsuitableproteomes.txt

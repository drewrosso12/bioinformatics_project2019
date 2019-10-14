# usage bash mcrA.sh './ref_sequences/mcrAgene_*.fasta' './proteomes/proteome_*.fasta'

#concatenates all of the mcrA reference sequences into one document
cat $1 >> mcrA.refs
#takes the refernce sequence .fasta file and uses muscle to align it 
./muscle -in mcrA.refs -out mcrAalign.fasta
#takes the aligned reference sequences and uses hmmbuild to form hidden markov model of alignment
./hmmer/bin/hmmbuild buildmcrA.hmm mcrAalign.fasta

#for each of the proteome samples (1-50) we use hmm search to see if it contains the mcrA gene 
for files in $2
do
	recordName=$(echo $files | sed 's/.fasta//g')
	./hmmer/bin/hmmsearch buildmcrA.hmm $files > $recordName.txt
	proteome=$(echo $recordName | sed 's/.\/proteomes\///g')
	#create summary table collating results -- if there is an mcrA gene then it will give the coenzyme name -- if not it indicates there were no hits for that proteome
	echo -n  $proteome " " 
	cat $recordName.txt | egrep -o -m 1 "(coenzyme-B sulfoethylthiotransferase subunit alpha |\[No hits detected that satisfy reporting thresholds\])"
	echo -n  $proteome " " >> summary.txt
        cat $recordName.txt | egrep -o -m 1 "(coenzyme-B sulfoethylthiotransferase subunit alpha |\[No hits detected that satisfy reporting thresholds\])" >>summary.txt
done
#takes only those proteomes with mcrA gene and creates txt file with the name of associated proteome
cat summary.txt | egrep "coenzyme-B sulfoethylthiotransferase subunit alpha" |cut -d ' ' -f 1,1 >> namesofsuitableproteomes.txt

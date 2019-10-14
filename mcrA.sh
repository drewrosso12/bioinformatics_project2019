# usage bash mcrA.sh 'mcrAgene_*.fasta' 'proteome_*.fasta'

cat $1 >> mcrA.refs
./muscle -in mcrA.refs -out mcrAalign.fasta
./hmmer/bin/hmmbuild buildmcrA.hmm mcrAalign.fasta
for files in $2
do
	recordName=$(echo $files | sed 's/.fasta//g')
	./hmmer/bin/hmmsearch buildmcrA.hmm $files > $recordName.txt
done

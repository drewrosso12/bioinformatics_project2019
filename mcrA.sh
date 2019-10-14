# usage bash mcrA.sh 'mcrAgene_*.fasta'

for file in $1
do
	cat $1 >> mcrA.refs
done

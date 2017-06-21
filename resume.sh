#! /bin/sh

profile=$(curl -s 'http://api.bryangilbert.com/profile')

dots() {
    for i in $(seq 1 $1)
    do
        printf "."
        sleep 0.03
    done
}

extract() {
    if [ -z "$2" ]
    then
     echo "$profile" | jq -r -c ".$1"
    else
     echo "$2" | jq -r -c ".$1"
    fi
}

bio() {
    extract "bio.$1"
}

# Extract and display basic bio information

firstname=$(bio 'firstname')
lastname=$(bio 'lastname')
middlename=$(bio 'middlename')
suffix=$(bio 'suffix')
email=$(bio 'email')
phone=$(bio 'phone')
occupation=$(bio 'title')

printf "\nAccessing Subject Records"
dots 40
printf "\033[92mCOMPLETE\033[0m\n\n"

cat << STOP
  Name:        $firstname $middlename $lastname $suffix
  Occupation:  $occupation
  Email:       $email
  Phone:       $phone
STOP


# Extract and display social accounts (aliases)

printf "\n\nCross Referencing Known Aliases"
dots 34
printf "\033[92mCOMPLETE\033[0m\n\n"

github=$(bio 'githubUsername')
twitter=$(bio 'twitterUsername')
linkedin=$(bio 'linkedinUsername')

cat << STOP
  Github:   $github
  Twitter:  $twitter
  LinkedIn: $linkedin
STOP


# Extract and display education

printf "\n\nAccessing Government Education Records"
dots 27
printf "\033[92mCOMPLETE\033[0m\n\n"

(extract 'education[]') | while read edu; do
    school=$(extract 'school' "$edu")
    degree=$(extract 'degree' "$edu")
    major=$(extract 'major' "$edu")
    start=$(extract 'startDate' "$edu")
    end=$(extract 'graduatedDate' "$edu")
    startYear=$(date -d @$((start/1000)) "+%Y")
    endYear=$(date -d @$((end/1000)) "+%Y")

    cat << END
  $school
    - Major: $major
    - Degree: $degree
    - Years: $startYear - $endYear

END
done


# Extract and display job history

printf "\nLocating Employment Information"
dots 34
printf "\033[92mCOMPLETE\033[0m\n\n"

(extract 'jobs[]') | while read job; do

    company=$(extract 'job.company' "$job")
    title=$(extract 'positions[0].title' "$job")
    start=$(extract 'job.start' "$job")
    end=$(extract 'job.end' "$job")
    startYear=$(date -d @$((start/1000)) "+%Y")
    if [[ "$end" == "null" ]]
    then
        endYear="Present"
    else
        endYear=$(date -d @$((end/1000)) "+%Y")
    fi

    cat << END
  $company
    - Role: $title
    - Years: $startYear - $endYear

END
done


# Extract and display skills

printf "\nEvaluating Technological Proficienies"
dots 28
printf "\033[92mCOMPLETE\033[0m\n\n"

(extract 'proficiencies[]') | while read prof; do
    title=$(extract 'title' "$prof")
    echo "  - $title"
done


# Show link to resume
printf "\n\n******* Analysis Complete *******\n"
printf "View Full Report: http://bryangilbert.com/etc/resume\n\n"

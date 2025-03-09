#!/bin/bash

# Initialize score
score=0

# Function to ask a question
ask_question() {
    question="$1"
    options=("$2" "$3" "$4" "$5")
    correct_answer="$6"

    echo "$question"
    echo "1) ${options[0]}"
    echo "2) ${options[1]}"
    echo "3) ${options[2]}"
    echo "4) ${options[3]}"

    read -p "Enter your choice (1-4): " user_answer

    if [ "$user_answer" == "$correct_answer" ]; then
        echo "Correct!"
        ((score++))
    else
        echo "Wrong answer!"
    fi
    echo ""
}

# Quiz Questions
ask_question "1. What does the OpenAirInterface (OAI) project offer ?" \
             " A 5G Core Network" " A 3GPP-compliant 5G RAN implementation" "A Radio simulation" "A gNB simulation" 2

ask_question "2. What is one of the functions of the CU in the RAN ?" \
             "Manages radio frequency" "Serves as the aggregation point of the RAN" "Processes MAC and PHY layers" "Only routes traffic to DU" 2

ask_question "3. What is one of the roles of the DU in the RAN?" \
             "Manages UE authentication" "Radio resource management (PRBs)" "Manages session establishment" "Allocates IP addresses" 2

ask_question "4. Which interface connects the CU and DU according to the O-RAN architecture?" \
             "N2" "N3" "F1" "S1" 3

ask_question "5. What does RFSimulator emulate in OAI?" \
             "Full gNB stack" "radio transmissions" "Open5gs" "performance testing" 3

ask_question "6. Which interface connects the CU to the UPF ?" \
             "N3" "F3" "O3" "N2" 1

ask_question "7. What kind of tunnel exists between the CU and the UPF?" \
             "UDP" "TCP" "GTP" "ICMP" 3

ask_question "8. What is a limitation of RFSimulator?" \
             "Requires expensive hardware" "Does not model real RF conditions accurately" "Cannot connect to Open5GS" "Needs manual packet capture" 2

ask_question "9. What security feature does OAI CU support?" \
             "PDCP Ciphering & Integrity Protection" "UE SIM Encryption" "MAC Layer Security" "Custom NAS Security" 1

ask_question "10. What is the purpose of deploying an OAI UE in a namespace?" \
             "To enable multiple UE simulations" "To avoid IP conflicts" "To bypass authentication" "To improve latency" 1

# Display final score
echo "Quiz completed! Your final score is: $score / 10"

# Provide feedback
if [ "$score" -eq 10 ]; then
    echo "Excellent! You have a deep understanding of OAI, CU, DU, and RFSimulator!"
elif [ "$score" -ge 7 ]; then
    echo "Good job! You have a solid grasp of the concepts."
elif [ "$score" -ge 5 ]; then
    echo "Not bad! You might want to review some key areas."
else
    echo "Keep studying! OAI and RFSimulator have a lot to explore."
fi
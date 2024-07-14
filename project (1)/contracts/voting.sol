// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract voting {

    //address of the contract owner 
    address contractAddressOwner;

    //time when the voting start
    uint voting_start_time;

    constructor() {
        contractAddressOwner = msg.sender;
        voting_start_time = block.timestamp;
    }

    //candidate name -> hash of personal data relation
    mapping (string => bytes32) candidate_ID;

    //candidate name -> number of votes relation
    mapping (string => uint) candidate_votes;

    //all candidate names
    string [] candidates;

    //all voters identity hash
    bytes32 [] voters;

    
    //with this function candidate is being registered
    //a hash is created for his data, and then we store the info in candidate_ID and in all candidates
     function candidateRegistration(string memory _candidateName, uint _candidateAge, string memory _candidateId) public {
        //the current time plus 5 minutes
        require(block.timestamp<=(voting_start_time + 5 minutes), "Candidates can no longer be submitted");
        bytes32 candidate_hash = keccak256(abi.encodePacked(_candidateName, _candidateAge, _candidateId));
        candidate_ID[_candidateName] = candidate_hash;
        candidates.push(_candidateName);
        
    }

    
    //with this function we can see all the candidates
    function seeCandidates() public view returns(string[] memory) {
        return candidates;
    }

     
     //with this function, you can vote for some candidate
     //first we create a hash of the voter address
     //second, we check if he is in the list of voters, if he is that means that he has already voted
     //if he is not we calculate the vote and put him in the list of voters
     //the flag variable is true if he vote for candidate in the list of candidates
     //then we finally add the vote
    function Vote(string memory _candidate) public {

        require(block.timestamp<=voting_start_time + 5 minutes, "Voting time expired.");
        
        bytes32 voter_hash = keccak256(abi.encodePacked(msg.sender));

        for(uint i = 0; i < voters.length; i++){
            require(voters[i] != voter_hash, "You have already voted!");
        }

        voters.push(voter_hash);
        
        bool flag = false;
        
        for(uint j = 0; j < candidates.length; j++){
            if(keccak256(abi.encodePacked(candidates[j])) == keccak256(abi.encodePacked(_candidate))){
                flag=true;
            }
        }
        require(flag==true, "No such candidate present.");
        
        candidate_votes[_candidate]++;
    }

     
     //we send the candidate name, and we can see how many votes he has
    function seeVotes(string memory _candidate) public view returns(uint) {
        return candidate_votes[_candidate];
    }

   //function that transform uint to string
function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
        return "0";
    }
    
    uint j = _i;
    uint len;
    
    while (j != 0) {
        len++;
        j /= 10;
    }
    
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    
    while (_i != 0) {
        bstr[k--] = bytes1(uint8(48 + _i % 10));
        _i /= 10;
    }
    
    return string(bstr);
}



    //see the results of the voting
    function seeResults() public view returns(string memory){
        string memory results;
        
        for(uint i = 0; i < candidates.length; i++){
            results = string(abi.encodePacked(results, "(", candidates[i], ", ", uint2str(seeVotes(candidates[i])), ")---"));
        }
                return results;
    }

    //we can see the winner
    function Winner() public view returns(string memory){

        require(block.timestamp>(voting_start_time + 5 minutes), "Voting is still in progress");
        
        string memory winner= candidates[0];
        bool flag;
        
        for(uint i = 1; i <candidates.length; i++){
            
            if(candidate_votes[winner] < candidate_votes[candidates[i]]){
                winner = candidates[i];
                flag=false;
            }else{
                if(candidate_votes[winner] == candidate_votes[candidates[i]]){
                    flag=true;
                }
            }
        }
        
        if(flag==true){
            winner = "Equal votes between candidates. No winner!";
            
        }
        return winner;
    }

}
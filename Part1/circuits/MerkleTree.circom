pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var hashingCount = 0;

    for(var i = 0; i < n; i++){
        hashingCount += (2**i);
    }

    component hashing[hashingCount];

    for(var i = 0; i < hashingCount; i++){
        hashing[i] = Poseidon(2);
    }

    // To hash the given leaf hashes 
    for (var i = 0; i < 2 ** (n - 1); i++) {
        hashing[i].inputs[0] <== leaves[i * 2];
        hashing[i].inputs[1] <== leaves[(i * 2) + 1];
    }

    // To hash the intermediate hashes
    var j = 0;
    for (var i = 2 ** (n - 1); i < hashingCount; i++) {
        hashing[i].inputs[0] <== hashing[2 * j].out;
        hashing[i].inputs[1] <== hashing[(2 * j) + 1].out;
        j++;
    }

    root <== hashing[hashingCount - 1].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    // [assignment] insert your code here to compute the root from a leaf and elements along the path

    component hashes[n];
    component switcher[n];

    var tree[n+1];
    tree[0] = leaf;

    for (var i = 0; i < n; i++) {

        hashes[i] = Poseidon(2);
        switcher[i] = Switcher();
        
        switcher[i].sel <== path_index[i];
        switcher[i].L <== tree[i];       
        switcher[i].R <== path_elements[i];

        hashes[i].inputs[0] <== switcher[i].outL;
        hashes[i].inputs[1] <== switcher[i].outR;

        tree[i+1] = hashes[i].out;
    }

    root <== hashes[n-1].out;
}
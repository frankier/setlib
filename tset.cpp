#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "tset.h"

using namespace tset;

const size_t bit_size_aelem = sizeof(aelem)*8;
const aelem left_one =((aelem) 1)<<(bit_size_aelem-1);

TSet::TSet(int tree_length) {
    this->tree_length=tree_length;
    array_len=tree_length/bit_size_aelem+1;
    bitdata=new aelem[array_len];
    erase();
}

void TSet::add_item(int item) {
    bitdata[item/bit_size_aelem] |= left_one>>(item%bit_size_aelem);
}

bool TSet::has_item(int item) {
     return (bitdata[item/bit_size_aelem] & left_one>>(item%bit_size_aelem));
}

void TSet::intersection_update(TSet *other) {

    assert(tree_length==other->tree_length);

    for (int i=0;i<array_len;i++) {
        bitdata[i]&=other->bitdata[i];
        
    }
}

void TSet::union_update(TSet *other) {
    assert(tree_length==other->tree_length);
    for (int i=0;i<array_len;i++) {
        bitdata[i]|=other->bitdata[i];
    }
}

void TSet::minus_update(TSet *other) {
    assert(tree_length==other->tree_length);
    for (int i=0;i<array_len;i++) {
        bitdata[i]&=~other->bitdata[i];
    }
}

void TSet::erase() {
    memset(bitdata, 0, array_len*sizeof(aelem));
}

void TSet::copy(TSet *other) {
    assert(tree_length==other->tree_length);
    memcpy(bitdata,other->bitdata,array_len*sizeof(aelem));
}



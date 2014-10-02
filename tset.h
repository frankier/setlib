typedef unsigned long aelem;

namespace tset {
class TSet {
    public:
        int tree_length;
        int array_len;
        aelem *bitdata;

        TSet(int length);
        void intersection_update(TSet *other);
        void union_update(TSet *other);
        void minus_update(TSet *other);
        void erase();
        void copy(TSet *other);

};
}
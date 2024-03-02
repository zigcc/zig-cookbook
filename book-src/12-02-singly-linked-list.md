# Linked List (Singly)

Singly [linked list] contains nodes linked together, the list contains:
- `head`, head of the list, used for traversal.
- `tail`, tail of the list, used for fast add.
- `len`, length of the list

Operations that can be performed on singly linked lists include:
- Insertion O(1)
- Deletion O(n), which is the most complex since it need to maintain head/tail pointer.
- Traversal O(n)

```zig
{{#include ../src/12-02.zig }}
```

[linked list]: https://en.wikipedia.org/wiki/Linked_list

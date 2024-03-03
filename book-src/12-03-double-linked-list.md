# Linked List (Doubly)

A Doubly [linked list] contains nodes that are linked together in both directions, allowing for more efficient operations in some scenarios. Each node in a doubly linked list contains:
- `data`, the value stored in the node.
- `next`, a pointer to the next node in the list.
- `prev`, a pointer to the previous node in the list.

The list itself maintains:
- `head`, the head of the list, used for traversal from the start.
- `tail`, the tail of the list, used for traversal from the end and fast additions.
- `len`, the length of the list, tracking the number of nodes.

Operations that can be performed on doubly linked lists include:
- Insertion at the end O(1), based on the `tail` pointer.
- Insertion at arbitrary positions O(n), due to traversal requirements.
- Deletion O(n), with improved efficiency compared to singly linked lists because it could easily remove nodes in this list without a full traversal.
- Traversal from either end O(n), providing flexibility in how the list is navigated.


```zig
{{#include ../src/12-02.zig }}
```

[double linked list]: https://en.wikipedia.org/wiki/Doubly_linked_list

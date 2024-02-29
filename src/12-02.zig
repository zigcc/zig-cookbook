const std = @import("std");
const Allocator = std.mem.Allocator;
     
fn LinkedList(comptime T:type) type{
	return struct{
		const Node = struct{
			data:T,
			next:?*Node = null,
		};
		     
		root:?*Node=null,
		    
		allocator:Allocator,
		const Self = @This();
		     
		fn init(allocator:Allocator) Self {
			return Self{.allocator = allocator};
		}
		     
		fn add(self:*Self,value:T) !void {
			var node = try self.allocator.create(Node);
			node.* = Node{.data = value};
			if(self.root==null){
				self.root = node;
				return;
			}
			     
			var head:?*Node = self.root;
			while(head) |h|{
				if(h.next==null){
					h.next = node;
					return;
				}
				     
				head = h.next;
			}
		}
		 
		fn print(self:*Self,comptime printFunc:fn(object:T)void) void {
			var node = self.root;
			while(node) |n|{
				printFunc(n.data);
				node = n.next;
			}
		}
		     
		fn deinit(self:*Self) void{
			const alc = self.allocator;
			var node = self.root;
			while(node) |n|{
				const addr = n.next;
				alc.destroy(n);
				node = addr;
			}
		}
		
		fn count(self:*Self) usize {
			var counter:usize = 0;
			var node = self.root;
			while(node) |n|{
				counter +=1;
				node = n.next;
			}
			return counter;
		}
	};
}


const Book = struct{
	name:[]const u8,
	price:f32,
};

pub fn main() !void{
	var alc = std.heap.page_allocator;

	var nos = LinkedList(u32).init(alc);
	defer nos.deinit();
	
	try nos.add(32);
	try nos.add(20);
	try nos.add(21);
	
	nos.print(printNos);
	
	var list = LinkedList(Book).init(alc);
	defer list.deinit();
	     
	try list.add(Book{.name="PHP",.price=232.2});
	try list.add(Book{.name="Java",.price=82.2});

	  
	list.print(printFunction);
}

fn printNos(no:u32) void {
	std.debug.print("{d}\n",.{no});
}

fn printFunction (book:Book) void {
		std.debug.print("{s} {d:3.2}\n",.{book.name,book.price});
}
 

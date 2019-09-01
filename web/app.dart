import 'dart:html';
import 'dart:math';

class Todo {
  String text;
  String status;
  String key;

  Todo(String text, String status, String key) {
    this.text = text;
    this.status = status;
    this.key = key;
  }
}

class App {
  List<Todo> store;
  InputElement todoInput;
  Element todoList;
  Element footer;
  Element filters;
  Element all;
  Element active;
  Element completed;
  Element clearBtn;
  String status;

  App() {
    this.filters = querySelector('.filters');
    List<Element> filters = this.filters.querySelectorAll('li');
    this.store = [];
    this.todoInput = querySelector('.new-todo');
    this.todoList = querySelector('.todo-list');
    this.footer = querySelector('.footer');
    this.clearBtn = querySelector('.clear-completed');
    this.all = filters[0];
    this.active = filters[1];
    this.completed = filters[2];
    this.status = 'all';
    resetCount();
    this.listenCreate();
    this.listenToggle();
    listenClear();
  }

  listenCreate() {
    todoInput.onKeyDown.listen((KeyboardEvent e) {
      if (e.keyCode == 13 && todoInput.value.isNotEmpty) {
        Todo todo = addTodo(todoInput.value);
        todoList.children.add(createTodo(todo));
        resetCount();
      }
    });
  }

  addTodo(text) {
    Todo todo = Todo(text, 'active', Random().nextInt(100000).toString());
    store.add(todo);
    return todo;
  }

  createTodo(todo) {
    InputElement input = InputElement()
      ..className = 'toggle'
      ..type = "checkbox";

    Element label = LabelElement()..text = todo.text;

    Element button = ButtonElement()..className = 'destroy';

    Element div = DivElement()
      ..className = 'view'
      ..children.addAll([input, label, button]);

    Element li = LIElement()
      ..children.add(div)
      ..setAttribute('key', todo.key);

    if (todo.status == 'completed') {
      li.classes.add('completed');
      input.checked = true;
    }

    input.onClick.listen((e) {
      if (input.checked) {
        li.classes.add('completed');
        todo.status = 'completed';
      } else {
        li.classes.remove('completed');
        todo.status = 'active';
      }
    });

    button.onClick.listen((e) {
      store.removeAt(store.indexOf(todo));
      li.remove();
      resetCount();
    });
    return li;
  }

  resetCount({status = 'all'}) {
    if (store.isEmpty) {
      footer.style.display = 'none';
    } else {
      footer.style.display = 'block';
    }

    num count = 0;

    if (status == 'all') {
      count = store.length;
    } else {
      store.forEach((e) {
        if (e.status == status) {
          count++;
        }
      });
    }

    footer.querySelector('.todo-count').querySelector('strong').text =
        count.toString();
  }

  listenToggle() {
    this.filters.querySelectorAll('li').onClick.listen((e) {
      all.querySelector('a').classes.remove('selected');
      active.querySelector('a').classes.remove('selected');
      completed.querySelector('a').classes.remove('selected');
      Element target = e.currentTarget;
      target.querySelector('a').classes.add('selected');

      String status = target.getAttribute('todo-type');
      this.status = status;
      this.filterTodo(status);
    });
  }

  filterTodo(status) {
    todoList.children.clear();
    List<LIElement> lis = [];
    store.forEach((e) {
      if (status == 'all') {
        LIElement li = createTodo(e);
        lis.add(li);
        return;
      }
      if (e.status == status) {
        LIElement li = createTodo(e);
        lis.add(li);
      }
    });
    todoList.children.addAll(lis);
    resetCount(status: status);
  }

  listenClear() {
    clearBtn.onClick.listen((e) {
      this.store.removeWhere((e) => e.status == 'completed');
      this.filterTodo(status);
    });
  }
}

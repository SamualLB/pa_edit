require "dot_prison"
require "gobject/gtk/autorun"

module PAEdit
  VERSION = "0.1.0"
end
def build_iters(store : Gtk::TreeStore, prison : DotPrison::Table, parent : Gtk::TreeIter? = nil)
  prison.each do |k, v|
    tree = Gtk::TreeIter.new
    store.append(tree, parent)
    case v
    in DotPrison::Table
      store.set tree, {0, 1}, {k, "[#{v.size}]"}
      build_iters store, v, tree
    in String
      store.set tree, {0, 1}, {k, v}
    in Array(DotPrison::Table)
      store.set tree, {0, 1}, {"#{k}[]", "[#{v.size}]"}
      v.each_with_index do |val, i|
        child = Gtk::TreeIter.new
        store.append child, tree
        store.set child, {0, 1}, {i.to_s, "[#{val.size}]"}
        build_iters store, val, child
      end
    in Array(String)
      store.set tree, {0, 1}, {k, v.to_s}
    end
  end
end

prison = DotPrison.parse(ARGV[0])

builder = Gtk::Builder.new_from_file "#{__DIR__}/../template.glade"
builder.connect_signals

store = Gtk::TreeStore.cast builder["tree_store"]
build_iters(store, prison)
#root = Gtk::TreeIter.new
#store.append(root, nil)
#store.set(root, {0}, {"Root"})

#child = Gtk::TreeIter.new
#store.append(child, root)
#store.set(child, {0}, {"Child"})

window = Gtk::Window.cast builder["main_window"]
window.connect "destroy", &->Gtk.main_quit
window.show_all


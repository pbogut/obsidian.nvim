local util = require "obsidian.util"
local Path = require "plenary.path"

describe("obsidian.util", function()
  it("should correctly URL-encode a path", function()
    assert.equals(util.urlencode [[~/Library/Foo Bar.md]], [[~%2FLibrary%2FFoo%20Bar.md]])
  end)
  it("should match case of key to prefix", function()
    assert.equals(util.match_case("Foo", "foo"), "Foo")
    assert.equals(util.match_case("In-cont", "in-context learning"), "In-context learning")
  end)
  it("should remove refs and links from a string", function()
    assert.equals(util.replace_refs "Hi there [[foo|Bar]]", "Hi there Bar")
    assert.equals(util.replace_refs "Hi there [[Bar]]", "Hi there Bar")
    assert.equals(util.replace_refs "Hi there [Bar](foo)", "Hi there Bar")
    assert.equals(util.replace_refs "Hi there [[foo|Bar]] [[Baz]]", "Hi there Bar Baz")
  end)
  it("should find positions of all refs", function()
    local s = "[[Foo]] [[foo|Bar]]"
    local matches = util.find_refs(s)
    local expected = { { 1, 7 }, { 9, 19 } }
    assert.equals(#matches, #expected)
    for i, match in ipairs(matches) do
      assert.equals(match[1], expected[i][1])
      assert.equals(match[2], expected[i][2])
    end
  end)
  it("should find and replace all refs", function()
    local s, indices = util.find_and_replace_refs "[[Foo]] [[foo|Bar]]"
    local expected_s = "Foo Bar"
    local expected_indices = { { 1, 3 }, { 5, 7 } }
    assert.equals(s, expected_s)
    assert.equals(#indices, #expected_indices)
    for i = 1, #indices do
      assert.equals(indices[i][1], expected_indices[i][1])
      assert.equals(indices[i][2], expected_indices[i][2])
    end
  end)
  it("should relink refs to a new link", function()
    local old_id = "foo"
    local new_id = "bar"
    local line = "- [[foo|Foo]] and [[foo]] and [Foo](foo)"
    local new_line, replaced = util.relink_refs(line, old_id, new_id)
    assert.equals(replaced, true)
    assert.equals(new_line, "- [[bar|Foo]] and [[bar]] and [Foo](bar)")
  end)
  it("should convert a list of params into a string", function()
    local as_string = util.table_params_to_str { "find", "/home/user/obsidian", "-name", "*.md" }
    assert.equals(as_string, "find /home/user/obsidian -name *.md")
  end)
  it("should recursively find notes in a directory given a file name", function()
    local matches = util.find_note(".", "foo.md")
    assert.equals(#matches, 1)
    assert.equals(tostring(matches[1]), "./test_fixtures/notes/foo.md")
  end)
  it("should recursively find notes in a directory given a partial path", function()
    local matches = util.find_note(".", "notes/foo.md")
    assert.equals(#matches, 1)
    assert.equals(tostring(matches[1]), "./test_fixtures/notes/foo.md")
  end)
end)

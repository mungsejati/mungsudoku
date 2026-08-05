import os
import re

def parse_dart_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    entities = []
    current_doc = []
    
    class_pattern = re.compile(r'^(?:abstract\s+)?class\s+([A-Za-z0-9_]+)')
    enum_pattern = re.compile(r'^enum\s+([A-Za-z0-9_]+)')
    mixin_pattern = re.compile(r'^mixin\s+([A-Za-z0-9_]+)')
    extension_pattern = re.compile(r'^extension\s+([A-Za-z0-9_]+)')
    
    # Very basic method pattern: returnType methodName(args)
    # We'll just look for indented things that look like methods or fields if they have docs.
    # To keep it simple, we'll track the current class and just capture anything with doc comments.
    
    in_class = None
    
    for i, line in enumerate(lines):
        line_stripped = line.strip()
        
        if line_stripped.startswith('///'):
            current_doc.append(line_stripped[3:].strip())
            continue
            
        if not line_stripped or line_stripped.startswith('//'):
            # Ignore empty lines or normal comments, but don't clear doc
            if not line_stripped.startswith('//'):
                pass
            continue
            
        # Check for class/enum/mixin
        c_match = class_pattern.match(line) or enum_pattern.match(line) or mixin_pattern.match(line) or extension_pattern.match(line)
        if c_match:
            name = c_match.group(1)
            doc_str = " ".join(current_doc) if current_doc else "Tidak ada deskripsi spesifik."
            entities.append({'type': 'class', 'name': name, 'doc': doc_str, 'members': []})
            current_doc = []
            in_class = name
            continue
            
        # Check for methods/functions inside class
        # Very rough heuristic: has parenthesis, doesn't start with keywords like if, for, while
        if in_class and current_doc and '(' in line_stripped and not line_stripped.startswith('@'):
            # Ignore control structures
            if not any(line_stripped.startswith(kw) for kw in ['if', 'for', 'while', 'switch', 'catch', 'return']):
                # Attempt to extract method name
                m = re.search(r'([A-Za-z0-9_]+)\s*\(', line_stripped)
                if m:
                    m_name = m.group(1)
                    if m_name != in_class: # Ignore constructor
                        doc_str = " ".join(current_doc)
                        entities[-1]['members'].append({'name': m_name, 'doc': doc_str})
        
        # Check for top-level functions (if not in class)
        if not in_class and current_doc and '(' in line_stripped and not line_stripped.startswith('@'):
            if not line_stripped.startswith('import ') and not line_stripped.startswith('export '):
                m = re.search(r'([A-Za-z0-9_]+)\s*\(', line_stripped)
                if m:
                    m_name = m.group(1)
                    doc_str = " ".join(current_doc)
                    entities.append({'type': 'function', 'name': m_name, 'doc': doc_str})

        # Clear doc if it wasn't used for a class/method
        if not line_stripped.startswith('@'):
            current_doc = []
            
    return entities

def main():
    lib_dir = 'lib'
    markdown_lines = []
    
    markdown_lines.append("## `lib` Directory")
    markdown_lines.append("Folder ini berisi seluruh *source code* (kode sumber) dari aplikasi MungSudoku. Berikut adalah penjabaran file dan fungsinya:\n")
    
    for root, dirs, files in os.walk(lib_dir):
        for file in sorted(files):
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                rel_path = os.path.relpath(filepath, lib_dir)
                entities = parse_dart_file(filepath)
                
                markdown_lines.append(f"### 📄 `lib/{rel_path}`")
                
                if not entities:
                    markdown_lines.append("- *File ini berisi konfigurasi, konstanta, atau widget UI tanpa deskripsi spesifik.*\n")
                    continue
                    
                for ent in entities:
                    if ent['type'] == 'class':
                        markdown_lines.append(f"- **Class/Widget `{ent['name']}`**: {ent['doc']}")
                        for mem in ent['members']:
                            markdown_lines.append(f"  - `function {mem['name']}()`: {mem['doc']}")
                    elif ent['type'] == 'function':
                        markdown_lines.append(f"- **Function `{ent['name']}()`**: {ent['doc']}")
                markdown_lines.append("")
                
    # Append to README.md
    with open('README.md', 'a', encoding='utf-8') as f:
        f.write("\n" + "\n".join(markdown_lines))
        
if __name__ == '__main__':
    main()

import re
import sys

def fix_isar_web(file_path):
    import io
    with io.open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all integer literals in the file (id: <number>)
    # We will look for numbers that might be too large for JS.
    # A safe JS integer is up to 2**53 - 1 (9007199254740991)
    
    def replace_large_int(match):
        num_str = match.group(1)
        try:
            num = int(num_str)
            if abs(num) > 9007199254740991:
                # Convert to float and back to int to get the JS-representable value
                # Alternatively, just truncate it using bitwise or modulo, but Dart compiler
                # explicitly wants the 'nearest representable value'.
                # Let's use Python's float conversion which matches IEEE 754 double precision
                js_num = int(float(num))
                return str(js_num)
        except:
            pass
        return num_str

    # Regex to find integer literals assigned to 'id:' or standalone long numbers
    # We can just target any long sequence of digits, optionally with a minus sign
    # But to be safe and only target schema IDs, let's look for 'id: <number>' or 'id: -<number>'
    
    # Actually, the errors are all like `id: -2005826577402374815`
    # Let's replace any number in the file that's large, but be careful not to mess up strings.
    # Isar generated files don't have large numbers in strings that we care about replacing.
    
    pattern = re.compile(r'(-?\d{16,})')
    
    new_content = pattern.sub(replace_large_int, content)
    
    with io.open(file_path, 'w', encoding='utf-8') as f:
        f.write(unicode(new_content) if sys.version_info[0] < 3 else new_content)
        
    print("Fixed isar_models.g.dart for Web!")

if __name__ == "__main__":
    fix_isar_web(sys.argv[1])

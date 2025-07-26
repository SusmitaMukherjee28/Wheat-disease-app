import shutil
import os

# Full path to the extracted dataset
source_root = r'C:\Users\susmi\Downloads\Newdataset\Dataset'
destination_root = 'Dataset'  # This should be your existing dataset folder in your project

categories = ['Yellow Rust', 'Septoria', 'Loose Smut', 'Healthy', 'Brown Rust']

for category in categories:
    src_folder = os.path.join(source_root, category)
    dst_folder = os.path.join(destination_root, category)
    os.makedirs(dst_folder, exist_ok=True)

    if not os.path.exists(src_folder):
        print(f"Source folder does not exist: {src_folder}")
        continue

    for file_name in os.listdir(src_folder):
        src_path = os.path.join(src_folder, file_name)
        dst_path = os.path.join(dst_folder, file_name)
        if os.path.isfile(src_path):
            shutil.move(src_path, dst_path)

print("All category images moved successfully.")
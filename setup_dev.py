#!/usr/bin/env python3
"""Setup development environment for AeroBeat Assembly"""

import subprocess
import os
import sys

def run_command(cmd, cwd=None):
    """Run a shell command and return success status"""
    print(f">>> {cmd}")
    result = subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)
    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr, file=sys.stderr)
    return result.returncode == 0

def setup_submodules():
    """Initialize and update git submodules"""
    print("Setting up git submodules...")
    
    # Check if we're in a git repo
    if not os.path.exists(".git"):
        print("Warning: Not a git repository. Submodules may not work correctly.")
        return False
    
    submodules = [
        ("../aerobeat-core", "addons/aerobeat-core"),
        ("../aerobeat-input-mediapipe-python", "addons/aerobeat-input-mediapipe")
    ]
    
    for source, dest in submodules:
        if not os.path.exists(dest):
            print(f"Adding submodule: {source} -> {dest}")
            if not run_command(f'git submodule add "{source}" "{dest}"'):
                print(f"Failed to add submodule {source}")
                return False
    
    # Initialize and update
    if not run_command("git submodule update --init --recursive"):
        print("Failed to update submodules")
        return False
    
    print("Submodules configured successfully")
    return True

def verify_structure():
    """Verify the expected directory structure exists"""
    print("Verifying directory structure...")
    
    required_paths = [
        "addons/aerobeat-core/src/interfaces/input_provider.gd",
        "addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd",
        "src",
        "scenes",
        "test"
    ]
    
    all_exist = True
    for path in required_paths:
        if os.path.exists(path):
            print(f"  ✓ {path}")
        else:
            print(f"  ✗ {path} (will be created)")
            all_exist = False
    
    return all_exist

def create_directories():
    """Create necessary directories"""
    dirs = ["src", "scenes", "test/unit", "test/integration"]
    for d in dirs:
        os.makedirs(d, exist_ok=True)
        print(f"Created: {d}")

def update_project_plugins():
    """Update project.godot to enable plugins"""
    print("Updating project.godot plugin configuration...")
    
    plugin_section = """
[editor_plugins]
enabled=PackedStringArray("res://addons/aerobeat-core/plugin.cfg", "res://addons/aerobeat-input-mediapipe/plugin.cfg")
"""
    
    project_file = "project.godot"
    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False
    
    with open(project_file, "r") as f:
        content = f.read()
    
    # Check if already has editor_plugins
    if "[editor_plugins]" in content:
        print("Plugin configuration already exists")
        return True
    
    # Append plugin section
    with open(project_file, "a") as f:
        f.write(plugin_section)
    
    print("Plugin configuration added")
    return True

def main():
    print("=== AeroBeat Assembly Setup ===\n")
    
    # Create directories
    create_directories()
    
    # Setup submodules
    if not setup_submodules():
        print("\nWarning: Submodule setup had issues. You may need to configure manually.")
    
    # Verify structure
    verify_structure()
    
    # Update plugins
    update_project_plugins()
    
    print("\n=== Setup complete ===")
    print("Next steps:")
    print("1. Open this project in Godot 4.6")
    print("2. Install Python dependencies: cd addons/aerobeat-input-mediapipe && ./install_deps.sh")
    print("3. Run the project!")

if __name__ == "__main__":
    main()

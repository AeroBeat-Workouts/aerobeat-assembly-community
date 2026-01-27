import os
import subprocess

def main():
    print("🔧 Setting up Assembly Environment...")
    
    # Ensure addons folder exists
    if not os.path.exists("addons"):
        os.makedirs("addons")
        
    # Clone Core (Required for everything)
    if not os.path.exists("addons/aerobeat-core"):
        print("  + Cloning Core...")
        subprocess.run(["git", "clone", "https://github.com/AeroBeat-Workouts/aerobeat-core.git", "addons/aerobeat-core"])

    # Clone UI Core (Required for UI Logic)
    if not os.path.exists("addons/aerobeat-ui-core"):
        print("  + Cloning UI Core...")
        subprocess.run(["git", "clone", "https://github.com/AeroBeat-Workouts/aerobeat-ui-core.git", "addons/aerobeat-ui-core"])

    # Clone GUT (Required for Testing)
    if not os.path.exists("addons/gut"):
        print("  + Cloning GUT...")
        subprocess.run(["git", "clone", "https://github.com/bitwes/Gut.git", "addons/gut"])

if __name__ == "__main__":
    main()
# AeroBeat Assembly Template

This is the official template for creating an **Assembly** repository within the AeroBeat ecosystem.

An **Assembly** is the "Game Client." It is the top-level Godot project that ties together the Core, Input Drivers, UI Shells, and Feature modules into a playable executable.

## 📋 Repository Details

*   **Type:** Assembly (Game Client)
*   **License:** **GNU GPLv3** (Strict Copyleft)
*   **Dependencies:**
    *   `aerobeat-core` (Required)
    *   `aerobeat-ui-core` (Required)
    *   `aerobeat-tool-*` (Services / As needed)
    *   `aerobeat-input-*` (As needed)
    *   `aerobeat-ui-shell-*` (As needed)
    *   `aerobeat-ui-kit-*` (As needed / Transitive)
    *   `aerobeat-feature-*` (As needed)
    *   `aerobeat-asset-*` (Internal Assets / As needed)

## 🚀 Getting Started

1.  **Clone your new repo:**
    ```bash
    git clone https://github.com/YourOrg/aerobeat-assembly-custom.git
    ```
2.  **Run Setup:**
    Initialize the environment and download dependencies.
    ```bash
    python setup_dev.py
    ```
3.  **Open in Godot:**
    Import the `project.godot` file into Godot 4.x.

## 🧪 Testing & CI/CD

This template comes pre-configured with **GUT (Godot Unit Test)** workflows.

*   **Local Testing:** Run tests via the "GUT" panel in the Godot Editor.
*   **CI/CD:** A GitHub Action (`.github/workflows/gut_ci.yml`) runs automatically on every push to `main`.
*   **Requirement:** 100% Code Coverage is enforced.

## 📂 Structure

*   `addons/` - Submodules (Core, UI, Input). Managed by `setup_dev.py`.
*   `src/` - Application-specific logic (Main Loop, Scene Switching).
*   `test/` - Unit tests mirroring the `src/` structure.
*   `assets/` - Local assets (Splash screens, icons).
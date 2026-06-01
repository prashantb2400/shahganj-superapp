#!/bin/bash
# Shahganj Git Upload Helper

echo "----------------------------------------------------"
echo "🚀 Linking Remote & Uploading Shahganj Superapp..."
echo "----------------------------------------------------"

# Link or update remote url
git remote add origin https://github.com/prashantb2400/shahganj-superapp.git 2>/dev/null || git remote set-url origin https://github.com/prashantb2400/shahganj-superapp.git

# Set main branch
git branch -M main

# Push repository code and release version tags
echo "🔑 Please enter your GitHub credentials if prompted below:"
git push -u origin main
git push origin v1.0.0

echo "----------------------------------------------------"
echo "✅ Upload completed! Cloud compilation triggered."
echo "----------------------------------------------------"

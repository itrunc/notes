#If PYTHONPATH hadn't been added
SETX PYTHONPATH "new_path_to\site-packages"

#Go to the source code folder

pip install --target="%PYTHONPATH%" .

#Or for no dependents
pip install --target="%PYTHONPATH%" --no-deps .

#Re-Install
pip install --target="%PYTHONPATH%" --force-reinstall .

#Show current installed packages
pip freeze

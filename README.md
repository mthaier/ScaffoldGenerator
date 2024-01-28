# Custom scaffolds generation

Create custom scaffolds to fit your structures once and generate them whenever you want. Made with Bash.

## Usage
Connecting an alias to the script path is recommended.

`sca -p new` Create a new profile(a profile contains all your templates and keys)
`sca -p ProfileName valueForKey1 valueForKey2...valueForKeyN.` Scaffold


I'll write docs later, however you'd use it like the following `sca -p new` to make new profile and stuff and then generate the scaffold with `scp -s ProfileName Key1Value Key2Value...KeyNValue`

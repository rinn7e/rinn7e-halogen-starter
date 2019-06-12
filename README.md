# Opinionated Purescript Halogen Starter

## Feature
- Contain router system built-in
- Default `BigPrelude` to contain shared module
- Halogen HTML helper, Affjax(Http) Helper
- Development command, Production command

## Limitation
- Not that good code convention (I am a still a noob purescript programmer)
- Still need a lot of cleanup 
- Opinionated:
I created this for my own project, but hopefully somebody will find this useful. You should build on top of this, or just use this as an example to get started. (Pull Request is welcomed)

## Convention

- Most common type and function should be put in `BigPrelude`, ex: Effect, Aff
- Shared HTML is put in `Shared.Layout`, various helper function is put in `Shared.Helper`
- Any custom data structure (`Page`, `Todo`, `User`) is put in `Data` dir
- Shared component should be put in `Shared` dir, in a sub dir `Component` or `Template` or anyth you prefer
- Individual Page is put in `Page` dir
- Env var is put in `config` dir, we will pass it into compile using `include`, ex `pscid -I lib:config/dev`


## Get Started
- Pre-requisite
```bash
npm i -g purescript #main-compiler
npm i -g pscid@2.8.1 #fast reload
npm i -g spago #manage package and build
npm i -g parcel-bundler #fast build tool for development
```

- Clone and Install dependency
```bash
git clone git@github.com:rinn7e/rinn7e-halogen-starter.git && cd rinn7e-halogen-starter
spago install
```

### Fast Development Loop
```bash


pscid # this will run `npm run build` or `spago build -p 'lib/**/*.purs' 'config/dev/**/*.purs'`

#click-b to build, then it will auto-reload when code changed, some changes required full build again, click-b to build again

# this will compile to commonjs in output dir, to actually see it in browser, we use parcel, see command below
```
in another terminal

```bash
parcel index.html #compile our output dir and serve in localhost:1234
```

### Prepare for Production

```bash
spago bundle-module -p 'lib/**/*.purs' 'config/dev/**/*.purs' -t dist-prod/prod.js
# this will compile to optimize js, then we can <script> src it in prod index.html
```

# Footer
```
យកព្រះអាទិត្យធ្វើដែក​កេស
ដុតជកដល់ថ្ងៃសៅរ៍

                                     
                                    . +~.                                       
                              .......?MN.,                                      
                    .  ..     .......,:::,...                                   
                    .  ..     .....,8D?ID$.,.          ..                       
                   .:8$..     ....,OM8O8ON$,......     +N+.                     
                ....I8O:...... .. .M8??IIDD:...........ODO,,    .               
                ...=8ZZN...... ...OMDZMM$8MN..........$7+$D....                 
                .,$D$M8D$........+DD$$$7$IDN?  ......?87ZINZ.,. .               
               ..~DM78Z$N+.......+M8I7?I7IZM$.......+DD$O$ZN:.... .             
               ..=M7I+?=ZZ......,OMI8MMMMDIMN.......Z8=+~+~8=. ...              
               .,MNZDD$D7M7.,...,DN+=======DN.. ...OMD7$D$$OD:....              
               .+NO$NDMN?M?.....IMMI8MMMMO=DMO.....?MIOMMM8+D+... .             
               .OMI~~===~D8.,...=DN77I7I?I7OM=. ..,8D+~~~:=+M$...               
              .~NM??MMMM?NMI....NMMZMMZ7MMZDMD,...+MM=7MMM8:NM:..               
        . .....,DN+~::::=DM....~NMMOD:ON:DODMN+,.,:DN+,:::~~M8........          
        .......IMM++D:7D,NMO.:=D=+~7:DMMD,$=?+N~..8M$,MO.8D~NMZ.......          
        .......I7~~I:8=$M:~~~~+N7:Z=$MMMMI+D=~N+===~=DD~N:O=:Z8.,... .          
        .....,.:~DM~?M8+=MN~::,$D~?:.I7$I,~D.NIII7DMM$=8M7+?NI=......           
        ....~$I7NMD:8.I8:D?N87$NO=+MOZOOZOM8:8MMMM8,N==Z:OI=NM$7$=....          
        ...8NOO8NNOMZZOZ8D,D=ZO$8.7N,8NMO,ND.D=:=,8.MZZOO$MN8MDDDM8...          
         ..8O~D.8N:N:DIZ?N:D+++Z8.:=.MMMN:~=.D=ZM,8.M+D~D,87ZD:Z7O8...          
         ..OO~Z,8N:D:N7OIN:8MNMMO.:+.MMMD:~:.8?~=~8.M=M:N,87ZN,$IOD...          
         ..ZMNDN8+.+:N7~:D:Z=.....?D,?++?.DD.?$77$O.M~~:N:?~~NNDDNO...          
       ..ZOZZZZ$Z88D8MDOZ8DNNDNNNNNM8DDD88MN8DD8DDDDDDD8MZDD8$$$$7$$ZZ          
        .M7777I777IZMMMMD7I7777777$MMMMMMMMZZ$$$$$$$Z8MMMMD$$$$$$Z$ZMM          
        .M~~~~:::~:?MMMMO::~::::::+MMMMMMMN+:~~::::::IMMMM$::::::::?MM          
       ..M=::::::::+MMMMO,,,,,,,,,~MMMMMMMM=,,,,,,,,,?MMMM7.......,?MM          
       ..MMMMMMMMMMMMMMM8=++++++++?MMMMMMMM+?+?++=?+=OMMMMMMMMMMMMMMMM          
                                                                       
```
<!-- ASCII credit to https://groups.google.com/forum/#!topic/campg/YlWT0Sezt5I -->

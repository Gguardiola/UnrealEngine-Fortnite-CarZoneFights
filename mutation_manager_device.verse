
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Vehicles }
using { /Fortnite.com/Playspaces }
using {/UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Random }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
mutation_manager_device := class(creative_device):
    @editable
    Mutant : mutator_zone_device = mutator_zone_device{}
    @editable
    TimerSwitch : switch_device = switch_device{}
    @editable
    ScoreManager : score_manager_device = score_manager_device{}
    @editable
    VisualsSafeZone : beacon_device = beacon_device{}
    @editable
    SafeZoneDeco : creative_prop = creative_prop{}

    #Maxpos
    @editable
    InsideSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    OutsideSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable var MinCoord : vector3 = vector3{}
    @editable var MaxCoord : vector3 = vector3{}
    @editable var SpawnCoords : []vector3 = array{}
    var NewSpawnCoords : vector3 = vector3{X:= 0.0, Y:=0.0, Z:=0.0}

    var isActive : logic = false
    var level : float = 0.0
    var Visualslevel : float = 0.0
    var offset : float = 0.0
    var AllPlayers : []player = array{}
    var newTrans : vector3 = vector3{X:=0.0,Y:=0.0,Z:=0.0}
    var isFirstCountdown : logic = true;
    var isSmallest : logic = false;
    var NewSpawn : int = 0;

    OnBegin<override>()<suspends>:void=
        set AllPlayers = GetPlayspace().GetPlayers()
        Print("Listening to zone changing")
        Mutant.AgentEntersEvent.Subscribe(OnPlayerEnters_class)
        Mutant.AgentExitsEvent.Subscribe(OnPlayerExits_class)
        spawn:
            CheckChangingListener()

    OnPlayerEnters_class(Agent : agent):void=
        Print("class listener - enters")
        InsideSelector.ChangeClass(Agent)

    OnPlayerExits_class(Agent : agent):void=
        Print("class listener - exits")  
        OutsideSelector.ChangeClass(Agent)      

    giveScoreToAlivePlayers():void=
        Print("Giving score")
        for(Player : AllPlayers){
            if(FortCharacter : fort_character = Player.GetFortCharacter[]){
                if(active := FortCharacter.IsActive[]){
                    Print("Increment score to player")
                    ScoreManager.Increment(Player)
                    ScoreManager.Activate(Player)
                }
            }
        }
    CheckChangingListener()<suspends>:void=
        loop:
            Sleep(0.2)
            set offset = offset + 0.2
            if(TimerSwitch.GetCurrentState[]){
                if(isFirstCountdown = true){
                    Print("First countodown")
                    Sleep(3.0)
                    set isFirstCountdown = false
                }
                #Print("Triggered Change Zone!")
                set NewSpawn = GetRandomInt(0, SpawnCoords.Length - 1)
                if(set NewSpawnCoords = SpawnCoords[NewSpawn]){}
                
                # NewX := GetRandomFloat(MinCoord.X, MaxCoord.X)
                # NewY := GetRandomFloat(MinCoord.Y, MaxCoord.Y)
                # NewZ := GetRandomFloat(MinCoord.Z, MaxCoord.Z)

                #if newTrans está en el rango del agujero, re randomizar!
                #hacer diferentes if por varias zonas cuadradas rodeando los agujeros, que decida cual newTrans usar
                CurrentScale := Mutant.GetTransform().Scale.X - level
                NewTrans := NewSpawnCoords
                Shrink := vector3{X:=CurrentScale, Y:=CurrentScale, Z:=Mutant.GetTransform().Scale.Z}


                NewCoord := transform{
                    Translation := NewTrans,
                    Rotation := Mutant.GetTransform().Rotation,
                    Scale := Shrink
                }

                VisualsNewCoord := transform{
                    Translation := vector3{X := NewSpawnCoords.X, Y := NewSpawnCoords.Y, Z:= NewSpawnCoords.Z + 390.0},
                    Rotation := VisualsSafeZone.GetTransform().Rotation,
                    Scale := VisualsSafeZone.GetTransform().Scale
                }
                if(VisualsSafeZone.TeleportTo[VisualsNewCoord]){Print("visuals teleported")}

                DecorNewCoord := transform{
                    Translation := vector3{X := NewSpawnCoords.X, Y := NewSpawnCoords.Y, Z:= NewSpawnCoords.Z},
                    Rotation := SafeZoneDeco.GetTransform().Rotation,
                    Scale := vector3{X := SafeZoneDeco.GetTransform().Scale.X - Visualslevel, Y := SafeZoneDeco.GetTransform().Scale.Y - Visualslevel, Z:= SafeZoneDeco.GetTransform().Scale.Z}
                }
                if(SafeZoneDeco.TeleportTo[DecorNewCoord]){Print("visuals teleported 2")}

                if(Mutant.TeleportTo[NewCoord]){
                    Sleep(31.5)
                    Print("Zone Changed! Go!")
                    if(isFirstCountdown = false){giveScoreToAlivePlayers()}
                    if(level <= 0.75 and isSmallest = false) {
                        set level = level + 0.15
                        if(level >= 0.30){
                            Print("TINY VISUALS")
                            set Visualslevel = Visualslevel + 0.01
                        }else{
                            set Visualslevel = Visualslevel + 0.04
                        }
                        
                    }
                    else {
                        set level = 0.0
                        set Visualslevel = 0.0
                        set isSmallest = true
                        Print("Is Smallest!")
                    }
                    
                    Print("New level {level}")
                    
                }
                
            }else{
                #Print("Waiting for zone change...")
            }

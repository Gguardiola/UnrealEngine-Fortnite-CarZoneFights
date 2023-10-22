
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Vehicles }
using { /Fortnite.com/Playspaces }
using {/UnrealEngine.com/Temporary/SpatialMath}

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
mutation_downVehicle_device := class(creative_device):

    @editable
    Mutant : mutator_zone_device = mutator_zone_device{}
    @editable
    Car : vehicle_spawner_nitro_drifter_sedan_device = vehicle_spawner_nitro_drifter_sedan_device{}
    @editable
    TimedSwitch : switch_device = switch_device{}
    @editable
    PlayerCounter : player_counter_device = player_counter_device{}


    var isOutsideMutation : logic = true
    var AllPlayers : []player = array{}
    var CurrentPlayer : []fort_character = array{}
    var isAlive: logic = true

    OnBegin<override>()<suspends>:void=
        set AllPlayers = GetPlayspace().GetPlayers()
    
        Mutant.AgentEntersEvent.Subscribe(OnPlayerEnters)
        Mutant.AgentExitsEvent.Subscribe(OnPlayerExits)
        spawn:
            AsyncPlayerChecker()
            

    AsyncPlayerChecker()<suspends>:void=
        loop:
            Sleep(0.1)
            if(isAlive = true){
                if(isOutsideMutation = true){
                    #Print("Danger!")
                    PlayerCounter.CountedEvent.Subscribe(OnPlayerCount)
                }else{
                    #Print("Safe!")
                }
            }else{
                break
            }

    OnPlayerCount(Agent : agent):void=
        Print("Counted")
        #not TimedSwitch.GetCurrentState[], 
        if(isOutsideMutation = true){   
            Print("Killable")
            if(FortCharacter : fort_character = Agent.GetFortCharacter[]){
                Print("is player")
                FortCharacter.Damage(100.0)
                set isAlive = false
            }
            else{
                Print("not a player")
            }                        
        }
        
    OnPlayerEnters(Agent : agent):void=
        set isOutsideMutation = true #false
        Print("Enters")  

    OnPlayerExits(Agent : agent):void=
        Print("Exit")
        set isOutsideMutation = true        
        

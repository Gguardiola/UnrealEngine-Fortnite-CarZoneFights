
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/UnrealEngine.com/Temporary/SpatialMath}

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
explode_detonator_device := class(creative_device):
    @editable
    Car : vehicle_spawner_nitro_drifter_sedan_device = vehicle_spawner_nitro_drifter_sedan_device{}
    @editable
    Bomb :explosive_device = explosive_device{}
    @editable
    BeaconProp : creative_prop = creative_prop{}
    @editable
    TimerSwitch : switch_device = switch_device{}
    @editable
    PowerUp : collectible_object_device = collectible_object_device{}
    @editable
    EliminationSound : audio_player_device = audio_player_device{}

    var CurrentPosition : vector3 = vector3{}
    var isAlive : logic = true

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Car.AgentEntersVehicleEvent.Subscribe(OnUpdateListener)
        PowerUp.CollectedEvent.Subscribe(OnGetPowerUp)
        #Car.AgentExitsVehicleEvent.Subscribe(OnDeathListener)

    OnGetPowerUp(Agent : agent):void=
        Print("Power Up!")
        

    OnDeathListener(Agent : agent):void=
        Print("Morido")
        set isAlive = false
        if(FortChar := Agent.GetFortCharacter[]){
            Print("{CurrentPosition}")
            if(BeaconProp.TeleportTo[CurrentPosition, rotation{}]){}
            spawn:
                ExplodeBomb(Agent)
        }

    EliminatePLayer(Result:elimination_result): void=
       #Print("eliminate player")
       #Print("Morido2")
        set isAlive = false
        EliminatedCharacter := Result.EliminatedCharacter
        if(EliminatedAgent := EliminatedCharacter.GetAgent[]){
            #Print("{CurrentPosition}")
            if(BeaconProp.TeleportTo[CurrentPosition, rotation{}]){}
            spawn:
                ExplodeBomb(EliminatedAgent)

        }
    
    OnUpdateListener(Agent : agent): void=
        if(FortChar : fort_character = Agent.GetFortCharacter[]){
            spawn:
                UpdatePosition(FortChar)

        }

    UpdatePosition(FortChar : fort_character)<suspends>:void=
        loop:
            if(isAlive = false){
                break
            }else{
                FortChar.EliminatedEvent().Subscribe(EliminatePLayer)
                Sleep(0.2)
                set CurrentPosition = FortChar.GetTransform().Translation
                #Print("new pos: {CurrentPosition}")
                
            }
    ExplodeBomb(Agent : agent)<suspends>:void=
        #Sleep(10.0)
        EliminationSound.Play()
        Bomb.Explode(Agent)


            




            
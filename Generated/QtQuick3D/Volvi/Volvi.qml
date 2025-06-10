import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    property url textureData: "maps/textureData.png"
    property url textureData43: "maps/textureData43.png"
    property url textureData127: "maps/textureData127.png"
    property url textureData85: "maps/textureData85.png"
    property url textureData20: "maps/textureData20.png"
    property url textureData130: "maps/textureData130.jpg"
    property url textureData17: "maps/textureData17.png"
    property url textureData31: "maps/textureData31.png"
    property url textureData133: "maps/textureData133.jpg"
    property url textureData60: "maps/textureData60.png"
    property url textureData135: "maps/textureData135.jpg"
    property url textureData9: "maps/textureData9.png"
    property url textureData35: "maps/textureData35.png"
    property url textureData57: "maps/textureData57.png"
    property url textureData40: "maps/textureData40.png"
    Texture {
        id: volvi_fbm_brake_disc_Base_Color_jpg_texture
        objectName: "volvi.fbm/brake_disc_Base Color.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData130
    }
    Texture {
        id: volvi_fbm_priora_dirt_png_texture
        objectName: "volvi.fbm/priora_dirt.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData35
    }
    Texture {
        id: volvi_fbm_carpet_png_texture
        objectName: "volvi.fbm/carpet.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData31
    }
    Texture {
        id: volvi_fbm_vehiclelights128_png_texture
        objectName: "volvi.fbm/vehiclelights128.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData
    }
    Texture {
        id: volvi_fbm_1_png_texture
        objectName: "volvi.fbm/1.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData60
    }
    Texture {
        id: volvi_fbm_torpedo_png_texture
        objectName: "volvi.fbm/torpedo.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData43
    }
    Texture {
        id: volvi_fbm_tirethread_png_texture
        objectName: "volvi.fbm/tirethread.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData40
    }
    Texture {
        id: volvi_fbm_2_png_texture
        objectName: "volvi.fbm/2.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData57
    }
    Texture {
        id: volvi_fbm_sidewall_png_texture
        objectName: "volvi.fbm/sidewall.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData127
    }
    Texture {
        id: volvi_fbm_salon2_png_texture
        objectName: "volvi.fbm/salon2.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData20
    }
    Texture {
        id: volvi_fbm_clotch_png_texture
        objectName: "volvi.fbm/clotch.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData17
    }
    Texture {
        id: volvi_fbm_headlight4_png_texture
        objectName: "volvi.fbm/headlight4.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData85
    }
    Texture {
        id: volvi_fbm_plane_divided_DefaultMaterial_BaseColor_jpg_texture
        objectName: "volvi.fbm/plane_divided_DefaultMaterial_BaseColor.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData133
    }
    Texture {
        id: volvi_fbm_plane_divided_DefaultMaterial_Normal_jpg_texture
        objectName: "volvi.fbm/plane_divided_DefaultMaterial_Normal.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData135
    }
    Texture {
        id: volvi_fbm_bbb_png_texture
        objectName: "volvi.fbm/bbb.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData9
    }

    // Nodes:
    Node {
        id: rootNode
        objectName: "RootNode"
        Model {
            id: chassis
            objectName: "chassis"
            y: 83.22643280029297
            z: 1.5060245990753174
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/chassis_mesh.mesh"
            materials: [
                chassis_002_material,
                chassis_007_material,
                car_Paint_001_material,
                chassis_013_material,
                chassis_014_material,
                chassis_016_material,
                chassis_017_material,
                glass_002_material,
                chassis_018_material,
                chassis_019_material,
                chassis_020_material,
                chassis_021_material,
                chassis_022_material,
                exhaust,
                exhaust,
                chassis_023_material
            ]
            Model {
                id: salon
                objectName: "salon"
                y: -0.5483386516571045
                z: 0.02892640046775341
                source: "meshes/salon_mesh.mesh"
                materials: [
                    chassis_014_material,
                    chassis_019_material,
                    chassis_020_material,
                    salon_001_material,
                    ar3DMat_Procedural_Realistic_Mirror_material,
                    salon_008_material,
                    salon_009_material,
                    salon_010_material
                ]
            }
            Model {
                id: torpeda
                objectName: "torpeda"
                x: 0.00011834502220153809
                y: -0.48270750045776367
                z: 0.005881526507437229
                source: "meshes/torpeda_mesh.mesh"
                materials: [
                    wheel_006_material,
                    chassis_019_material,
                    chassis_020_material,
                    chassis_021_material,
                    chassis_022_material,
                    salon_008_material,
                    salon_010_material,
                    torpeda_001_material,
                    torpeda_002_material,
                    torpeda_003_material,
                    torpeda_004_material,
                    torpeda_005_material,
                    torpeda_006_material,
                    torpeda_021_material,
                    torpeda_022_material,
                    torpeda_023_material,
                    torpeda_024_material,
                    torpeda_025_material,
                    torpeda_026_material,
                    torpeda_027_material,
                    torpeda_028_material
                ]
            }
            Model {
                id: sed
                objectName: "sed"
                y: -0.566779375076294
                z: -0.013143336400389671
                source: "meshes/sed_mesh.mesh"
                materials: [
                    chassis_020_material,
                    salon_008_material,
                    salon_010_material,
                    torpeda_001_material,
                    torpeda_002_material,
                    torpeda_004_material,
                    torpeda_005_material,
                    sed_001_material
                ]
            }
            Model {
                id: dvig
                objectName: "dvig"
                x: 2.086162567138672e-07
                y: 1.6503591537475586
                z: -0.1209542453289032
                source: "meshes/dvig_mesh.mesh"
                materials: [
                    carpaint_001_material,
                    chassis_013_material,
                    chassis_017_material,
                    chassis_018_material,
                    chassis_019_material,
                    chassis_021_material,
                    salon_001_material,
                    torpeda_004_material,
                    torpeda_006_material,
                    torpeda_021_material,
                    sed_001_material,
                    dvig_001_material,
                    dvig_002_material,
                    dvig_003_material,
                    dvig_004_material,
                    dvig_005_material,
                    dvig_006_material,
                    dvig_007_material,
                    dvig_008_material,
                    dvig_009_material,
                    dvig_010_material
                ]
            }
            Model {
                id: poliki
                objectName: "poliki"
                x: -0.0014762282371520996
                y: 0.2884555459022522
                z: -0.3812066912651062
                source: "meshes/poliki_mesh.mesh"
                materials: [
                    chassis_020_material,
                    torpeda_001_material
                ]
            }
            Model {
                id: bagajnik
                objectName: "bagajnik"
                y: -1.7264513969421387
                z: 0.055894866585731506
                source: "meshes/bagajnik_002_mesh.mesh"
                materials: [
                    torpeda_001_material
                ]
            }
            Model {
                id: pered_fars
                objectName: "pered fars"
                y: 2.0442538261413574
                z: -0.16092565655708313
                source: "meshes/pered_fars_mesh.mesh"
                materials: [
                    chassis_019_material,
                    chassis_020_material,
                    pered_fars_001_material,
                    pered_fars_004_material,
                    glass_004_material,
                    right_front_light_001_material
                ]
            }
            Model {
                id: zad_fars
                objectName: "zad fars"
                x: 1.1920928955078125e-07
                y: -1.9804341793060303
                z: 0.2639659345149994
                source: "meshes/zad_fars_mesh.mesh"
                materials: [
                    chassis_017_material,
                    chassis_019_material
                ]
                Model {
                    id: svet
                    objectName: "svet"
                    x: -8.940696716308594e-08
                    y: -0.05335891246795654
                    z: 0.0015977859729900956
                    source: "meshes/svet_002_mesh.mesh"
                    materials: [
                        right_front_light_001_material
                    ]
                }
            }
        }
        Model {
            id: bump_front_ok
            objectName: "bump_front_ok"
            y: 47.98147964477539
            z: -207.67092895507812
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/bump_front_ok_mesh.mesh"
            materials: [
                car_Paint_001_material,
                chassis_014_material,
                chassis_016_material,
                chassis_017_material,
                chassis_019_material,
                pered_fars_001_material,
                right_front_light_001_material,
                bump_front_ok_001_material
            ]
            Model {
                id: st
                objectName: "st"
                source: "meshes/st_002_mesh.mesh"
                materials: [
                    glass_002_material
                ]
            }
        }
        Model {
            id: bump_rear_ok
            objectName: "bump_rear_ok"
            y: 54.15471649169922
            z: 205.36227416992188
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/bump_rear_ok_mesh.mesh"
            materials: [
                car_Paint_001_material,
                chassis_014_material,
                chassis_017_material,
                chassis_018_material
            ]
        }
        Model {
            id: bonnet_ok
            objectName: "bonnet_ok"
            x: 76.09583282470703
            y: 101.28887939453125
            z: -110.43577575683594
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/bonnet_ok_mesh.mesh"
            materials: [
                car_Paint_001_material,
                chassis_013_material,
                chassis_014_material,
                chassis_017_material,
                salon_008_material,
                torpeda_005_material
            ]
        }
        Model {
            id: door_lf_ok
            objectName: "door_lf_ok"
            x: -90.20831298828125
            y: 69.33162689208984
            z: -91.33767700195312
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/door_lf_ok_mesh.mesh"
            materials: [car_Paint_001_material,chassis_013_material,chassis_014_material,chassis_017_material,car_windshield_glass_material,ar3DMat_Procedural_Realistic_Mirror_material,chassis_020_material,chassis_021_material,chassis_023_material,salon_008_material,torpeda_004_material,torpeda_025_material]
        }
        Model {
            id: door_rf_ok
            objectName: "door_rf_ok"
            x: 90.24566650390625
            y: 69.31157684326172
            z: -91.3326644897461
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/door_rf_ok_mesh.mesh"
            materials: [
                car_Paint_001_material,
                chassis_013_material,
                chassis_014_material,
                chassis_017_material,
                car_windshield_glass_material,
                ar3DMat_Procedural_Realistic_Mirror_material,
                chassis_020_material,
                chassis_021_material,
                chassis_023_material,
                salon_008_material,
                torpeda_004_material,
                torpeda_025_material
            ]
        }
        Model {
            id: door_lr_ok
            objectName: "door_lr_ok"
            x: -90.99348449707031
            y: 70.19422912597656
            z: 20.26344871520996
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/door_lr_ok_mesh.mesh"
            materials: [
                car_Paint_001_material,
                chassis_013_material,
                chassis_014_material,
                chassis_017_material,
                car_windshield_glass_material,
                chassis_018_material,
                chassis_019_material,
                chassis_020_material,
                chassis_021_material,
                salon_008_material,
                torpeda_004_material
            ]
        }
        Model {
            id: door_rr_ok
            objectName: "door_rr_ok"
            x: 91.02056884765625
            y: 70.1992416381836
            z: 20.268383026123047
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/door_rr_ok_mesh.mesh"
            materials: [
                car_Paint_001_material,
                chassis_013_material,
                chassis_014_material,
                chassis_017_material,
                car_windshield_glass_material,
                chassis_018_material,
                chassis_019_material,
                chassis_020_material,
                chassis_021_material,
                salon_008_material,
                torpeda_004_material
            ]
        }
        Model {
            id: boot_ok
            objectName: "boot_ok"
            x: -0.02135145477950573
            y: 145.8768310546875
            z: 170.8487091064453
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/boot_ok_mesh.mesh"
            materials: [
                car_Paint_001_material,
                chassis_014_material,
                chassis_017_material,
                car_windshield_glass_material,
                chassis_018_material,
                chassis_019_material,
                chassis_021_material,
                chassis_023_material,
                salon_008_material,
                torpeda_002_material,
                torpeda_003_material,
                torpeda_026_material,
                zad_fars_001_material,
                boot_ok_001_material,
                boot_ok_002_material
            ]
        }
        Model {
            id: windscreen_ok
            objectName: "windscreen_ok"
            y: 116.79852294921875
            z: -81.4337158203125
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/windscreen_ok_mesh.mesh"
            materials: [
                car_windshield_glass_material,
                glass_006_material
            ]
        }
        Model {
            id: wheel
            objectName: "wheel"
            x: 80.4911880493164
            y: 33.78385925292969
            z: -144.29669189453125
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/wheel_mesh.mesh"
            materials: [
                volvoV60RimBlack,
                boot_ok_001_material,
                wheel_001_material,
                wheel_006_material,
                brake_disc_material,
                volvoV60RimSilver
            ]
        }
        Model {
            id: wheel_001
            objectName: "wheel.001"
            x: 80.4911880493164
            y: 33.78385925292969
            z: 145.52505493164062
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/wheel_001_mesh.mesh"
            materials: [
                volvoV60RimBlack,
                boot_ok_001_material,
                wheel_001_material,
                wheel_006_material,
                brake_disc_material,
                volvoV60RimBlack
            ]
        }
        Model {
            id: wheel_002
            objectName: "wheel.002"
            x: -80.60848999023438
            y: 33.78385925292969
            z: 145.52505493164062
            rotation: Qt.quaternion(-2.24765e-08, 8.42937e-08, 0.707107, 0.707107)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/wheel_002_mesh.mesh"
            materials: [
                volvoV60RimBlack,
                boot_ok_001_material,
                wheel_001_material,
                wheel_006_material,
                brake_disc_material,
                volvoV60RimSilver
            ]
        }
        Model {
            id: wheel_003
            objectName: "wheel.003"
            x: -80.6085205078125
            y: 33.78385925292969
            z: -144.29669189453125
            rotation: Qt.quaternion(-2.24765e-08, 8.42937e-08, 0.707107, 0.707107)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/wheel_003_mesh.mesh"
            materials: [
                volvoV60RimBlack,
                boot_ok_001_material,
                wheel_001_material,
                wheel_006_material,
                brake_disc_material,
                volvoV60RimSilver
            ]
        }
    }

    Node {
        id: __materialLibrary__

        PrincipledMaterial {
            id: pered_fars_004_material
            objectName: "pered fars.004"
            baseColor: "#ff818181"
            roughness: 1
        }

        PrincipledMaterial {
            id: bump_front_ok_001_material
            objectName: "bump_front_ok.001"
            baseColor: "#ff000080"
            roughness: 1
        }

        PrincipledMaterial {
            id: right_front_light_001_material
            objectName: "right front light.001"
            baseColor: "#ff00ffc8"
            baseColorMap: volvi_fbm_vehiclelights128_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: glass_004_material
            objectName: "glass.004"
            baseColor: "#ff8c4600"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_010_material
            objectName: "dvig.010"
            baseColor: "#ff24242f"
            roughness: 1
        }

        PrincipledMaterial {
            id: pered_fars_001_material
            objectName: "pered fars.001"
            baseColorMap: volvi_fbm_headlight4_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: carpaint_001_material
            objectName: "carpaint.001"
            baseColor: "#ffff0000"
        }

        PrincipledMaterial {
            id: wheel_008_material
            objectName: "wheel.008"
            baseColor: "#ffcccccc"
            roughness: 0.5
        }

        PrincipledMaterial {
            id: metal_material
            objectName: "Metal"
            baseColor: "#ffcccccc"
            baseColorMap: volvi_fbm_plane_divided_DefaultMaterial_BaseColor_jpg_texture
            roughness: 0.5
            normalMap: volvi_fbm_plane_divided_DefaultMaterial_Normal_jpg_texture
        }

        PrincipledMaterial {
            id: brake_disc_material
            objectName: "Brake disc"
            baseColor: "#ffcccccc"
            baseColorMap: volvi_fbm_brake_disc_Base_Color_jpg_texture
            roughness: 0.5
        }

        PrincipledMaterial {
            id: wheel_001_material
            objectName: "wheel.001"
            baseColorMap: volvi_fbm_sidewall_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: procedural_Silver_material
            objectName: "Procedural Silver"
            baseColor: "#ffcccccc"
            roughness: 0.4000000059604645
        }

        PrincipledMaterial {
            id: glass_006_material
            opacity: 0.3
            objectName: "glass.006"
            baseColor: "#ffffff"
        }

        PrincipledMaterial {
            id: boot_ok_002_material
            objectName: "boot_ok.002"
            baseColor: "#ff080808"
            roughness: 1
        }

        PrincipledMaterial {
            id: boot_ok_001_material
            objectName: "boot_ok.001"
            baseColor: "#ff939393"
            roughness: 1
        }

        PrincipledMaterial {
            id: zad_fars_001_material
            objectName: "zad fars.001"
            baseColor: "#ff800000"
        }

        PrincipledMaterial {
            id: ar3DMat_Procedural_Realistic_Mirror_material
            clearcoatRoughnessAmount: 0
            clearcoatAmount: 1
            baseColor: "#f8f8f8"
            metalness: 1.0        // Vollständig metallisch
            roughness: 0.01

            objectName: "AR3DMat Procedural Realistic Mirror"
        }

        PrincipledMaterial {
            id: car_windshield_glass_material
            opacity: 0.1
            objectName: "Car windshield glass"
            baseColor: "#ffcccccc"
            roughness: 0.5
        }

        PrincipledMaterial {
            id: chassis_022_material
            objectName: "chassis.022"
            baseColor: "#ff121212"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_001_material
            objectName: "torpeda.001"
            baseColor: "#ff999999"
            baseColorMap: volvi_fbm_torpedo_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: wheel_006_material
            objectName: "wheel.006"
            baseColorMap: volvi_fbm_tirethread_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: salon_010_material
            objectName: "salon.010"
            baseColor: "#ff666666"
            baseColorMap: volvi_fbm_priora_dirt_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: salon_009_material
            objectName: "salon.009"
            baseColor: "#ff444444"
            roughness: 1
        }

        PrincipledMaterial {
            id: salon_008_material
            objectName: "salon.008"
            baseColor: "#ff999999"
            baseColorMap: volvi_fbm_carpet_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: salon_002_material
            objectName: "salon.002"
            baseColor: "#ff363636"
            roughness: 1
        }

        PrincipledMaterial {
            id: salon_001_material
            objectName: "salon.001"
            baseColor: "#ff232323"
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_023_material
            objectName: "chassis.023"
            baseColor: "#ff373737"
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_14_material
            objectName: "chassis.14"
            baseColor: "#ff4a4a4a"
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_13_material
            objectName: "chassis.13"
            baseColor: "#ff3f3f3f"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_002_material
            objectName: "torpeda.002"
            baseColor: "#ff1b1b1b"
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_021_material
            objectName: "chassis.021"
            baseColor: "#ff999999"
            baseColorMap: volvi_fbm_salon2_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_020_material
            clearcoatAmount: 0.1
            objectName: "chassis.020"
            baseColor: "#444444"
            roughness: 0.2
        }

        PrincipledMaterial {
            id: chassis_019_material
            metalness: 0.8
            objectName: "chassis.019"
            baseColor: "#ff999999"
            roughness: 0.3
        }

        PrincipledMaterial {
            id: chassis_018_material
            objectName: "chassis.018"
            baseColor: "#ff161616"
            roughness: 1
        }

        PrincipledMaterial {
            id: glass_002_material
            opacity: 0.2
            objectName: "glass.002"
            baseColor: "#ffffff"
        }

        PrincipledMaterial {
            id: chassis_017_material
            objectName: "chassis.017"
            baseColor: "#ff000000"
            roughness: 0.25
        }

        PrincipledMaterial {
            id: chassis_016_material
            objectName: "chassis.016"
            baseColor: "#ff0f0f0f"
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_014_material
            objectName: "chassis.014"
            baseColor: "#ff999999"
            baseColorMap: volvi_fbm_bbb_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_013_material
            objectName: "chassis.013"
            baseColor: "#ff030303"
            roughness: 1
        }

        PrincipledMaterial {
            id: car_Paint_001_material
            objectName: "Car Paint.001"

            baseColor: "#7A828D"
            metalness: 0.95
            roughness: 0.2
            clearcoatAmount: 0.4
            clearcoatFresnelBias: 0.2
            clearcoatFresnelScale: 1.5
            clearcoatFresnelScaleBiasEnabled: true
            normalStrength: 0.5
            lighting: PrincipledMaterial.FragmentLighting
            opacity: 1.0
            alphaMode: PrincipledMaterial.Default
        }

        PrincipledMaterial {
            id: chassis_007_material
            objectName: "chassis.007"
            baseColor: "#ff1e1e1e"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_028_material
            objectName: "torpeda.028"
            baseColorMap: volvi_fbm_1_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_008_material
            objectName: "dvig.008"
            baseColor: "#ff141414"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_007_material
            objectName: "dvig.007"
            baseColor: "#ff545041"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_006_material
            objectName: "dvig.006"
            baseColor: "#ff32362e"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_005_material
            objectName: "dvig.005"
            baseColor: "#ff1e1d17"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_004_material
            objectName: "dvig.004"
            baseColor: "#ff151c0f"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_003_material
            objectName: "dvig.003"
            baseColor: "#ff373737"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_002_material
            objectName: "dvig.002"
            baseColor: "#ff333333"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_001_material
            objectName: "dvig.001"
            baseColor: "#ff191919"
            roughness: 1
        }

        PrincipledMaterial {
            id: chassis_002_material
            objectName: "chassis.002"
            baseColor: "#ff292929"
            roughness: 1
        }

        PrincipledMaterial {
            id: sed_001_material
            objectName: "sed.001"
            baseColor: "#ff5b5b5b"
            roughness: 1
        }

        PrincipledMaterial {
            id: dvig_009_material
            objectName: "dvig.009"
            baseColor: "#ff2a2a2a"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_027_material
            objectName: "torpeda.027"
            baseColorMap: volvi_fbm_2_png_texture
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_026_material
            objectName: "torpeda.026"
            baseColor: "#ff111111"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_025_material
            objectName: "torpeda.025"
            baseColor: "#ff24334a"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_024_material
            objectName: "torpeda.024"
            baseColor: "#ff1a1a1a"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_023_material
            objectName: "torpeda.023"
            baseColor: "#ff272727"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_022_material
            objectName: "torpeda.022"
            baseColor: "#ff171717"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_021_material
            objectName: "torpeda.021"
            baseColor: "#ff252525"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_006_material
            objectName: "torpeda.006"
            baseColor: "#ff2d2d2d"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_005_material
            objectName: "torpeda.005"
            baseColor: "#ff303030"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_004_material
            objectName: "torpeda.004"
            baseColor: "#ff666666"
            roughness: 1
        }

        PrincipledMaterial {
            id: torpeda_003_material
            objectName: "torpeda.003"
            baseColor: "#ff1d1d1d"
            roughness: 1
        }

        PrincipledMaterial {
            id: volvoV60RimBlack
            baseColor: "#0A0A0A"  // Sehr dunkles Grau/Schwarz
            metalness: 0.35       // Kaum metallisch (lackiert/pulverbeschichtet)
            roughness: 0.1        // Leicht matte Oberfläche
            specularAmount: 0.5   // Wenig Spiegelung
            specularTint: 0.0     // Neutrale Spiegelungen

            // Weniger Reflexion als bei Metall
            indexOfRefraction: 1.3
            fresnelPower: 2.5

            // Kein Klarlack-Effekt
            clearcoatAmount: 0.2

            opacity: 1.0
            alphaMode: PrincipledMaterial.Opaque
            objectName: "Volvo V60 Rim Black"
        }

        PrincipledMaterial {
            id: volvoV60RimSilver
            objectName: "Volvo V60 Rim Silver"
            baseColor: "#C0C0C0"
            metalness: 0.95
            roughness: 0.1

            specularAmount: 1.0
            specularTint: 0

            indexOfRefraction: 1.5
            fresnelPower: 2.0

            clearcoatAmount: 0.5
            clearcoatRoughnessAmount: 0.05

            emissiveFactor: Qt.vector3d(0.0, 0.0, 0.0)
            opacity: 1.0
            alphaMode: PrincipledMaterial.Opaque
        }

        PrincipledMaterial {
            id: exhaust
            normalStrength: 0.05
            clearcoatAmount: 0.5
            clearcoatFresnelBias: 0.2
            clearcoatFresnelScale: 1.5
            clearcoatFresnelScaleBiasEnabled: true
            roughness: 0.1
            metalness: 1
            baseColor: "#bfbfbf"
            objectName: "exhaust"
        }
    }

    // Animations:
}

/*##^##
Designer {
    D{i:0;cameraSpeed3d:1;cameraSpeed3dMultiplier:1;matPrevEnvDoc:"SkyBox";matPrevEnvValueDoc:"preview_studio";matPrevModelDoc:"#Sphere"}
}
##^##*/

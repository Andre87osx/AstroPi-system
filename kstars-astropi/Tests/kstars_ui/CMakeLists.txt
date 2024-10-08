
SET(KSTARS_UI_TESTS_SRC
    kstars_ui_tests.cpp
    test_kstars_startup.cpp)

include_directories(${CFITSIO_INCLUDE_DIR})

ECM_ADD_APP_ICON(KSTARS_UI_TESTS_SRC ICONS
        ../../kstars/icons/16-apps-kstars.png
        ../../kstars/icons/32-apps-kstars.png
        ../../kstars/icons/48-apps-kstars.png
        ../../kstars/icons/64-apps-kstars.png
        ../../kstars/icons/128-apps-kstars.png
        )

QT5_ADD_RESOURCES(KSTARS_UI_TESTS_SRC ../../kstars/data/kstars.qrc)

ecm_qt_declare_logging_category(KSTARS_UI_TESTS_SRC HEADER test_ekos_debug.h IDENTIFIER KSTARS_EKOS_TEST CATEGORY_NAME org.kde.kstars.ekos.test)

IF (INDI_FOUND)

INCLUDE_DIRECTORIES(${INDI_INCLUDE_DIR})
SET(KSTARS_UI_EKOS_SRC ${KSTARS_UI_TESTS_SRC} test_ekos_wizard.cpp)
SET(KSTARS_UI_EKOS_LIBS ${TEST_LIBRARIES} ${CFITSIO_LIBRARIES} ${INDI_CLIENT_LIBRARIES} ${NOVA_LIBRARIES} z)

ADD_TEST(ui_xterm xterm)

# FIXME: this particular test crashes when done on the EGLFS platform
# Disabling until we find the reason, other tests do cover this scenario

# ADD_EXECUTABLE(test_ekos ${KSTARS_UI_EKOS_SRC} test_ekos.cpp)
# TARGET_LINK_LIBRARIES(test_ekos ${KSTARS_UI_EKOS_LIBS})
# ADD_TEST(NAME TestEkosProfiles COMMAND test_ekos)
# SET_TESTS_PROPERTIES( TestEkosProfiles PROPERTIES LABELS "stable;ui")

ADD_EXECUTABLE(test_ekos_simulator ${KSTARS_UI_EKOS_SRC} test_ekos_simulator.cpp)
TARGET_LINK_LIBRARIES(test_ekos_simulator ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestEkosSimulator COMMAND test_ekos_simulator)
# SET_TESTS_PROPERTIES( TestEkosSimulator PROPERTIES LABELS "stable;ui")

ADD_EXECUTABLE(test_ekos_focus ${KSTARS_UI_EKOS_SRC} test_ekos_focus.cpp)
TARGET_LINK_LIBRARIES(test_ekos_focus ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestEkosFocus COMMAND test_ekos_focus)
# SET_TESTS_PROPERTIES( TestEkosFocus PROPERTIES LABELS "stable;ui")

ADD_EXECUTABLE(test_ekos_capture ${KSTARS_UI_EKOS_SRC} test_ekos_capture.cpp)
TARGET_LINK_LIBRARIES(test_ekos_capture ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestEkosCapture COMMAND test_ekos_capture)
SET_TESTS_PROPERTIES( TestEkosCapture PROPERTIES LABELS "stable;ui" )

ADD_EXECUTABLE(test_ekos_capture_count ${KSTARS_UI_EKOS_SRC} test_ekos_helper.cpp test_ekos_capture_helper.cpp test_ekos_capture_count.cpp)
TARGET_LINK_LIBRARIES(test_ekos_capture_count ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestEkosCaptureCount COMMAND test_ekos_capture_count)
#SET_TESTS_PROPERTIES( TestEkosCaptureCount PROPERTIES LABELS "stable;ui" TIMEOUT 1200 )

ADD_EXECUTABLE(test_ekos_align ${KSTARS_UI_EKOS_SRC} test_ekos_helper.cpp test_ekos_align.cpp)
TARGET_LINK_LIBRARIES(test_ekos_align ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestEkosAlign COMMAND test_ekos_align)
SET_TESTS_PROPERTIES( TestEkosAlign PROPERTIES LABELS "unstable;ui" TIMEOUT 300 )

ADD_EXECUTABLE(test_ekos_meridianflip ${KSTARS_UI_EKOS_SRC} test_ekos_helper.cpp test_ekos_capture_helper.cpp test_ekos_meridianflip_base.cpp test_ekos_meridianflip.cpp)
TARGET_LINK_LIBRARIES(test_ekos_meridianflip ${KSTARS_UI_EKOS_LIBS})
# excluded to avoid CI timelimit failure
# ADD_TEST(NAME TestEkosMeridianFlip COMMAND test_ekos_meridianflip)
# SET_TESTS_PROPERTIES( TestEkosMeridianFlip PROPERTIES LABELS "astrometry;ui" )
ADD_CUSTOM_COMMAND( TARGET test_ekos_meridianflip POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/phd2_Simulators_mf.PHDGuidingV2
            ${CMAKE_CURRENT_BINARY_DIR}/.PHDGuidingV2_mf)

ADD_EXECUTABLE(test_ekos_meridianflip_specials ${KSTARS_UI_EKOS_SRC} test_ekos_helper.cpp test_ekos_capture_helper.cpp test_ekos_meridianflip_base.cpp test_ekos_meridianflip_specials.cpp)
TARGET_LINK_LIBRARIES(test_ekos_meridianflip_specials ${KSTARS_UI_EKOS_LIBS})
# excluded to avoid CI timelimit failure
# ADD_TEST(NAME TestEkosMeridianFlipSpecials COMMAND test_ekos_meridianflip_specials)
# SET_TESTS_PROPERTIES( TestEkosMeridianFlipSpecials PROPERTIES LABELS "unstable;ui" TIMEOUT 600 )

ADD_EXECUTABLE(test_ekos_scheduler ${KSTARS_UI_EKOS_SRC} test_ekos_scheduler.cpp)
TARGET_LINK_LIBRARIES(test_ekos_scheduler ${KSTARS_UI_EKOS_LIBS})
ADD_CUSTOM_COMMAND( TARGET test_ekos_scheduler POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/../scheduler/1x1s_Lum.esq
            ${CMAKE_CURRENT_BINARY_DIR}/1x1s_Lum.esq)
ADD_CUSTOM_COMMAND( TARGET test_ekos_scheduler POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/../scheduler/1x1s_RGBLumRGB.esq
            ${CMAKE_CURRENT_BINARY_DIR}/1x1s_RGBLumRGB.esq)
ADD_TEST(NAME TestEkosScheduler COMMAND test_ekos_scheduler)
SET_TESTS_PROPERTIES( TestEkosScheduler PROPERTIES LABELS "stable;ui" TIMEOUT 120 )

ADD_EXECUTABLE(test_artificial_horizon ${KSTARS_UI_EKOS_SRC} test_artificial_horizon.cpp)
TARGET_LINK_LIBRARIES(test_artificial_horizon ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestArtificialHorizon COMMAND test_artificial_horizon)

ADD_EXECUTABLE(test_ekos_guide ${KSTARS_UI_EKOS_SRC} test_ekos_guide.cpp)
TARGET_LINK_LIBRARIES(test_ekos_guide ${KSTARS_UI_EKOS_LIBS})
ADD_CUSTOM_COMMAND( TARGET test_ekos_guide POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/phd2_Simulators.PHDGuidingV2
            ${CMAKE_CURRENT_BINARY_DIR}/.PHDGuidingV2)
ADD_TEST(NAME TestEkosGuide COMMAND test_ekos_guide)
SET_TESTS_PROPERTIES( TestEkosGuide PROPERTIES LABELS "stable;ui" TIMEOUT 600 )

ADD_EXECUTABLE(test_ekos_mount ${KSTARS_UI_EKOS_SRC} test_ekos_mount.cpp)
TARGET_LINK_LIBRARIES(test_ekos_mount ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestEkosMount COMMAND test_ekos_mount)
SET_TESTS_PROPERTIES( TestEkosMount PROPERTIES LABELS "no-xvfb;ui" TIMEOUT 600 )

ADD_EXECUTABLE(test_catalog_download ${KSTARS_UI_EKOS_SRC} test_catalog_download.cpp)
TARGET_LINK_LIBRARIES(test_catalog_download ${KSTARS_UI_EKOS_LIBS})
ADD_TEST(NAME TestCatalogDownload COMMAND test_catalog_download)
SET_TESTS_PROPERTIES( TestCatalogDownload PROPERTIES LABELS "stable;ui" TIMEOUT 600 )

ELSE ()

# JM 2010-10-15: Disable this test due to issues in CI
#ADD_EXECUTABLE(test_kstars_ui ${KSTARS_UI_TESTS_SRC})
#TARGET_LINK_LIBRARIES(test_kstars_ui ${TEST_LIBRARIES})
#ADD_TEST(NAME TestKstarsUI COMMAND test_kstars_ui)

ENDIF ()

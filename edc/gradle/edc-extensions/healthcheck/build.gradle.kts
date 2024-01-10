/*
 *  Copyright (c) 2020, 2021 Microsoft Corporation
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the Apache License, Version 2.0 which is available at
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 *  SPDX-License-Identifier: Apache-2.0
 *
 *  Contributors:
 *       Microsoft Corporation - initial API and implementation
 *       Fraunhofer Institute for Software and Systems Engineering - added dependencies
 *
 */

plugins {
    `java-library`
    id("application")
    id("com.github.johnrengelman.shadow") version "7.1.2"
}

val edcGroupId: String by project
val edcVersion: String by project
val jakartaRsId: String by project
val jakartaRsVersion: String by project


dependencies {
    implementation("$edcGroupId:http:$edcVersion")
    implementation("$edcGroupId:connector-core:$edcVersion")
    implementation("$edcGroupId:boot:$edcVersion")

    implementation("$jakartaRsId:jakarta.ws.rs-api:$jakartaRsVersion")


}

application {
    mainClass.set("org.eclipse.edc.boot.system.runtime.BaseRuntime")
}

tasks.withType<com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar> {
    mergeServiceFiles()
    archiveFileName.set("connector-health.jar")
}

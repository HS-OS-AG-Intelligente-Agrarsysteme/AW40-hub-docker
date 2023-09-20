plugins {
    `java-library`

    id("application")
    id("com.github.johnrengelman.shadow") version "7.1.2"
}

val edcGroupId: String by project
val edcVersion: String by project

dependencies {
    implementation("$edcGroupId:core-spi:$edcVersion")
    implementation("$edcGroupId:web-spi:$edcVersion")
    implementation("$edcGroupId:federated-catalog-spi:$edcVersion")
    implementation("$edcGroupId:federated-catalog-core:$edcVersion")
    implementation("$edcGroupId:management-api-configuration:$edcVersion")
    implementation("$edcGroupId:json-ld:$edcVersion")
    implementation("$edcGroupId:json-ld-spi:$edcVersion")
    implementation("$edcGroupId:connector-core:$edcVersion")

    implementation("$edcGroupId:runtime-metamodel:$edcVersion")
    implementation("io.swagger.core.v3:swagger-annotations:2.2.15")

}

application {
    mainClass.set("org.eclipse.edc.boot.system.runtime.BaseRuntime")
}

tasks.withType<com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar> {
    exclude("**/pom.properties", "**/pom.xm")
    mergeServiceFiles()
    archiveFileName.set("federated-catalog-api.jar")
}

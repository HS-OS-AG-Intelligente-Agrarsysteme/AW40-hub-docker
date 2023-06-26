plugins {
    `java-library`
    id("application")
}

val groupId: String by project
val edcVersion: String by project

dependencies {
    implementation("$groupId:runtime-metamodel:$edcVersion")

    implementation("$groupId:data-plane-spi:$edcVersion")
    implementation("$groupId:control-plane-core:$edcVersion")
}

import { promises as fs } from 'fs';
import * as yaml from 'js-yaml';

enum VersionPosition {
    MAJOR,
    MINOR,
    PATCH,
}

type Position = keyof typeof VersionPosition;

const updateVersion = (currentVersion: string, position: Position): string => {
    const versionParts = currentVersion.split('.');
    const versionIndex = VersionPosition[position];
    if (versionIndex === undefined) {
        throw new Error('Invalid version position');
    }
    versionParts[versionIndex] = (parseInt(versionParts[versionIndex], 10) + 1).toString();
    console.log('Current version:', currentVersion)
    console.log('Position:', position)
    console.log('Version index:', versionIndex)
    console.log('New version part:', (parseInt(versionParts[versionIndex], 10) + 1))
    console.log('Version parts:', versionParts)
    // Reset lower versions if major or minor is incremented
    if (versionIndex === VersionPosition.MAJOR) {
        versionParts[1] = '0'; // Reset minor version if major is incremented
        versionParts[2] = '0'; // Reset patch version
    } else if (versionIndex === VersionPosition.MINOR) {
        versionParts[2] = '0'; // Reset patch version if minor is incremented
    }
    return versionParts.join('.');
};

const getCurrentVersion = async (filePath: string): Promise<string> => {
    const fileContents = await fs.readFile(filePath, 'utf8');
    const data = yaml.load(fileContents) as any; // Assuming the structure of the YAML content
    return data['version'].split('+')[0]; // Returns the current version without build number
};

const updateFileContent = async (filePath: string, currentVersion: string, newVersion: string): Promise<void> => {
    const content = await fs.readFile(filePath, 'utf8');
    const updatedContent = content.replace(new RegExp(currentVersion, 'g'), newVersion);
    await fs.writeFile(filePath, updatedContent, 'utf8');
};

const bumpVersion = async (position: Position): Promise<void> => {
    if (!(position in VersionPosition)) {
        console.error('Invalid version position argument:', position);
        return;
    }
    try {
        const filePath = '../pubspec.yaml'; // Flutter's main version file
        const currentVersion = await getCurrentVersion(filePath);
        const newVersion = updateVersion(currentVersion, position);
        const data = yaml.load(await fs.readFile(filePath, 'utf8')) as any; // Assuming the structure of the YAML content

        data['version'] = `${newVersion}${data['version'].substring(currentVersion.length)}`;
        const newYamlContent = yaml.dump(data);
        await fs.writeFile(filePath, newYamlContent, 'utf8');

        const filesToUpdate = ['../web/index.html', '../web/manifest.json', '../web/cacheWorker.js'];
        for (const file of filesToUpdate) {
            await updateFileContent(file, currentVersion, newVersion);
        }

        console.log('Version bumped to:', newVersion);
    } catch (error) {
        console.error('Error:', error);
    }
};

// Usage example
const position: Position = process.argv[2]?.toUpperCase() || 'PATCH';
bumpVersion(position);

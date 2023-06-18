import dataclasses
import os
import pathlib
import unittest

_current_dir_path: str = os.path.dirname(os.path.realpath(__file__))
_root_dir_path: str = os.path.dirname(os.path.dirname(_current_dir_path))

_no_tool_version = '<no tool_version>'

@dataclasses.dataclass
class ReleaseInfo:
    name: str = ''
    tool_version: str = ''
    skip_reason: str = dataclasses.field(default='', compare = False)


class VersionTests(unittest.TestCase):

    def get_release_info_from_workflow(self, name: str) -> ReleaseInfo:
        release_info = ReleaseInfo()
        workflow_file_path = os.path.join(_root_dir_path, '.github', 'workflows', f'{name}.yml')
        workflow_lines = pathlib.Path(workflow_file_path).read_text().splitlines()
        for line in workflow_lines:
            key, _, value = line.partition(':')
            stripped_key = key.strip()
            stripped_value = value.strip().strip("'")
            if stripped_key == 'name' and stripped_value == name:
                release_info.name = name
                continue
            if stripped_key == 'tool_version' and release_info.name and stripped_value:
                release_info.tool_version = stripped_value
                break
            if line.strip().startswith('# version_tests: skip_workflow'):
                release_info.skip_reason = line.strip()
            elif line.strip().startswith('# version_tests: skip_readme'):
                release_info.skip_reason = line.strip()

        if release_info.skip_reason == '# version_tests: skip_workflow':
            return release_info

        self.assertTrue(release_info.name, f"cannot get {name} 'name' in workflow")
        self.assertTrue(release_info.tool_version, f"Cannot get {name} 'tool_version' in workflow")

        return release_info

    def get_build_scripts(self, release_info: ReleaseInfo) -> list[str]:
        script_dir_path = os.path.join(_root_dir_path, release_info.name)
        build_scripts: list[str] = []
        for script_name in pathlib.Path(script_dir_path).iterdir():
            if script_name.name.startswith('build_'):
                build_scripts.append(script_name)

        self.assertTrue(build_scripts)
        return build_scripts

    def check_scripts_versions(self, release_info: ReleaseInfo) -> None:
        for build_script_path in self.get_build_scripts(release_info):
            self.check_script_versions(release_info, build_script_path)

    def check_script_versions(self, release_info: ReleaseInfo, build_script_path: str) -> None:
        script_lines = pathlib.Path(build_script_path).read_text().splitlines()
        script_info = ReleaseInfo()
        for line in script_lines:
            key, _, value = line.partition('=')
            stripped_key = key.strip()
            stripped_value = value.strip().strip('"')
            if stripped_key == 'tool_name':
                stripped_tool_name = pathlib.Path(stripped_value).stem
                if stripped_tool_name == release_info.name:
                    script_info.name = stripped_tool_name
                    continue
            if stripped_key == 'tool_version' and script_info.name and stripped_value:
                script_info.tool_version = stripped_value
                break
            if line.strip() == '# version_tests: no tool_version':
                script_info.tool_version = _no_tool_version
                break

        if script_info.tool_version == _no_tool_version:
            # check only name
            self.assertEqual(script_info.name, release_info.name)
            return

        self.assertEqual(script_info, release_info, build_script_path)

    @classmethod
    def dir_path_contains_script(cls, dir_path):
        return any((p for p in pathlib.Path(dir_path).iterdir() if p.name.endswith('.sh')))

    @classmethod
    def get_tools_dir_paths(cls) -> list[str]:
        tools_dir_paths = []
        for script_dir in pathlib.Path(_root_dir_path).iterdir():
            if not pathlib.Path(script_dir).is_dir():
                continue
            if script_dir.name.startswith('.'):
                continue
            if not cls.dir_path_contains_script(script_dir):
                continue

            tools_dir_paths.append(script_dir)

        return tools_dir_paths

    def get_line_from_readme(self, release_info: ReleaseInfo):
        readme_file_path = os.path.join(_root_dir_path, 'README.md')
        for line in pathlib.Path(readme_file_path).read_text().splitlines():
            stripped_line = line.strip()
            if f'https://github.com/hemnstill/StandaloneTools/releases/tag/{release_info.name}-' in stripped_line:
                return stripped_line

        self.assertTrue('', f"Cannot find line with '{release_info.name}' in readme.")

    def check_readme_versions(self, release_info: ReleaseInfo):
        readme_line = self.get_line_from_readme(release_info)
        self.assertEqual(3, readme_line.count(f'{release_info.name}-{release_info.tool_version}'),
                         f"Cannot find '{release_info}' in readme 3 times.")

    def test_version_match(self):
        tools_dir_paths = self.get_tools_dir_paths()
        self.assertTrue(tools_dir_paths)
        for tool_dir_path in tools_dir_paths:
            workflow_name = pathlib.Path(tool_dir_path).name
            release_info = self.get_release_info_from_workflow(workflow_name)
            if release_info.skip_reason == '# version_tests: skip_workflow':
                continue
            self.check_scripts_versions(release_info)
            if release_info.skip_reason == '# version_tests: skip_readme':
                continue
            self.check_readme_versions(release_info)



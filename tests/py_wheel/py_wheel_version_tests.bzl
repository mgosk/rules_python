# Copyright 2023 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Test for py_wheel."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", rt_util = "util")
load("@rules_testing//lib:truth.bzl", "matching")
load("//python:packaging.bzl", "py_wheel")

_tests = []

def _test_mandatory_version_param(name):
    rt_util.helper_target(
        py_wheel,
        name = name + "_subject",
        distribution = "mydist_" + name,
    )
    analysis_test(
        name = name,
        impl = _test_mandatory_version_param_impl,
        target = name + "_subject",
        expect_failure = True,
    )

def _test_mandatory_version_param_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("At least one of `version` or `version_file` must be set"),
    )

_tests.append(_test_mandatory_version_param)

def _test_mutually_exclusive_version_param(name):
    rt_util.helper_target(
        py_wheel,
        name = name + "_subject",
        distribution = "mydist_" + name,
        version = "0.0.0",
        version_file = ":version.txt",
    )
    analysis_test(
        name = name,
        impl = _test_mutually_exclusive_version_param_impl,
        target = name + "_subject",
        expect_failure = True,
    )

def _test_mutually_exclusive_version_param_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("Only one 'version' or 'version_file' may be set"),
    )

_tests.append(_test_mutually_exclusive_version_param)

def _test_version_from_param(name):
    rt_util.helper_target(
        py_wheel,
        name = name + "_subject",
        distribution = "mydist_" + name,
        version = "0.0.0",
    )
    analysis_test(
        name = name,
        impl = _test_version_from_param_impl,
        target = name + "_subject",
    )

def _test_version_from_param_impl(env, target):
    env.expect.that_target(target).default_outputs().contains(
        "{package}/mydist_{test_name}-0.0.0-py3-none-any.whl",
    )

_tests.append(_test_version_from_param)

def _test_version_from_file(name):
    rt_util.helper_target(
        py_wheel,
        name = name + "_subject",
        distribution = "mydist_" + name,
        version_file = ":version.txt",
    )
    analysis_test(
        name = name,
        impl = _test_version_from_file_impl,
        target = name + "_subject",
    )

def _test_version_from_file_impl(env, target):
    env.expect.that_target(target).default_outputs().contains(
        "{package}/mydist_{test_name}-0.0.0-py3-none-any.whla",
    )

_tests.append(_test_version_from_file)

def py_wheel_versions_test_suite(name):
    test_suite(
        name = name,
        tests = _tests,
    )

load("//build_support/python:python.bzl", "py_binary")

package(default_visibility = ["//visibility:public"])

py_binary(
    name = "inspect_execution_logs_cli",
    srcs = ["inspect_execution_logs_cli.py"],
    deps = [
        "//wayve/prototypes/robotics/vehicle_dynamics/common/flyte:inspect",
        "//wayve/services/data/pipelines/flyte/common:flyte_remote",
    ],
)

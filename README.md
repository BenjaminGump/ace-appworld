# ACE + AppWorld Experiments

This repository provides the full setup and instructions for running AppWorld experiments and reproducing the reported metrics, including offline and online adaptation with ACE.

> **⚠️ Important:**  
> Do **NOT** install this repository using `pip install appworld`.  
> This version includes custom modifications and must be installed **from source**.
> This repo is a research preview; please use it with caution in high-stakes production environments.

## 1. Environment Setup

Follow these steps exactly. Skipping steps may cause missing-file errors or silent failures. Setting up this repo and running basic experiments do not require GPU access. All you need is API access from providers like Together AI, SambaNova, or OpenAI.

### 1.1 Install Git LFS
```bash
git lfs install
```

### 1.2 Clone the repository
```bash
git clone https://github.com/BenjaminGump/ace-appworld.git ace-appworld
cd ace-appworld
export APPWORLD_PROJECT_PATH="$(pwd)"
```

### 1.3 Create virtual env for Python3.11 
Feel free to use other methods like conda if you wish
```bash
python3.11 -m venv .venv
source .venv/bin/activate
```

### 1.4 Install AppWorld from source
```bash
pip install -e .
pip install -e "experiments[simplified]"
appworld install --repo
```

### 1.5 Fetch data
```bash
appworld download data
```

## 2. Configure Experiment

### 2.1 Configure API Keys

API providers are configured via the ```provider``` field in the experiment config files. The framework currently supports Together AI, SambaNova, and OpenAI. Before running experiments, make sure to export the corresponding API keys that you need:
```bash
export TOGETHER_API_KEY=YOUR_API_KEY_HERE # export if necessary
export SAMBANOVA_API_KEY=YOUR_API_KEY_HERE # export if necessary
export OPENAI_API_KEY=YOUR_API_KEY_HERE # export if necessary
```

### 2.2 (Optional) Customize Configuration Files

Under ```experiments/configs```, you can customize the experiment you'd like to run by adding new or editing existing ```.jsonnet``` config files, including choice of language models and API providers, sampling parameters, system prompts, etc.

As an example, the following config snippet specifies that the reflector agent should use qwen3.7-plus as its language model, rely on the SambaNova API as the provider, and run with a sampling temperature of zero.
```
local reflector_model_config = {
    "name": "qwen3.7-plus",
    "provider": "sambanova",
    "temperature": 0,
    ...
};
```

You do not have to edit the configuration files if you just want to reproduce the results in our paper. 

### 2.3 (Optional) Customize Your Own ACE Agent

The definition of the ACE pipeline is under ```experiments/code/ace```, mostly in ```adaptation_react.py``` and ```evaluation_react.py```. We will follow up soon with more instructions on how to customize your ACE agent to support additional functionalities like context compression, retrieval, etc.

## 3. Run Experiments

Here is the basic format of running an experiment: ```appworld run CONFIG_FILE_NAME```.

### 3.1 Offline Context Adaptation with ACE

As an example, run the AppWorld + ACE (offline adaptation) experiment on the training split with:
```bash
appworld run ACE_offline_no_GT_adaptation
```

After we obtain the offline-optimized context, run evaluation on the test-normal split with:
```bash
appworld run ACE_offline_no_GT_evaluation
```
This step is essential as we need to collect the generations using the trained playbook. The output of this run will be evaluated in the below section, not the training run. 

### 3.1 Online Context Adaptation with ACE

As an example, run the AppWorld + ACE (online adaptation) experiment on the test-normal split with:
```bash
appworld run ACE_online_no_GT
```

## 4. Evaluate Results

After the run above completes, run the follow command to obtain the aggregated metrics. Replace ```CONFIG_FILE_NAME``` with the config file associated with your experiment (e.g., ```ACE_offline_no_GT_evaluation``` or ```ACE_online_no_GT```). This step does not generate any output, so make sure the configs you are evaluating have been run. This step should take no more than 2-3 minutes:
```bash
appworld evaluate CONFIG_FILE_NAME test_normal
appworld evaluate CONFIG_FILE_NAME test_challenge
```

Here is an example of a generated evaluation report (on the test-normal split):
| type         | task_goal_completion | scenario_goal_completion |
|--------------|----------------------|---------------------------|
| aggregate    | 64.9                 | 51.8                      |
| difficulty_1 | 86.0                 | 79.0                      |
| difficulty_2 | 77.1                 | 68.8                      |
| difficulty_3 | 36.5                 | 14.3                      |

We report aggregate TGC (```task_goal_completion```) and SGC (```scenario_goal_completion```) for evaluations in the paper.

## 5. Contact

If you have any questions, feel free to open a new issue or email at ```qizhengz@stanford.edu```. We’ll also be setting up a Slack/Discord channel soon to make communication easier.

## 6. Reference

If you find our work helpful, please use the following citation. Thank you for your support!
```
@article{zhang2025agentic,
  title={{Agentic Context Engineering: Evolving Contexts for Self-Improving Language Models}},
  author={Zhang, Qizheng and Hu, Changran and Upasani, Shubhangi and Ma, Boyuan and Hong, Fenglu and Kamanuru, Vamsidhar and Rainton, Jay and Wu, Chen and Ji, Mengmeng and Li, Hanchen and others},
  journal={arXiv preprint arXiv:2510.04618},
  year={2025}
}
```


## 7. Current tested Windows / OpenRouter reproduction

The setup below is the currently tested local configuration for this repository.

### 7.1 Runtime environment

The tested environment is Windows + Conda + Python 3.11. On every new CMD/Anaconda Prompt session, run:

```bat
cd /d C:\\gbz\\fucktest\\ace-appworld-git
conda activate ace_env
set APPWORLD_PROJECT_PATH=C:\gbzucktestce-appworld-git
set APPWORLD_ROOT=C:\gbzucktestce-appworld-git
set PYTHONUTF8=1
set "OPENAI_API_KEY=YOUR_OPENROUTER_KEY"
set "REPO=C:/gbz/fucktest/ace-appworld-git"
```

`PYTHONUTF8=1` is required on Windows because prompt/playbook files contain UTF-8 characters that may otherwise be decoded with a legacy Windows code page.

On Windows, AppWorld experiments must use `timeout_seconds=null`, because the upstream timeout helper relies on Unix `SIGALRM`. Keep `num_processes=1`; the multiprocessing CLI path also uses Unix process-group operations.

### 7.2 Model/API

The tested model is OpenRouter:

```text
~deepseek/deepseek-v4-flash-latest
```

The repository's current `provider="openai"` path is OpenAI-compatible and routes to OpenRouter in the customized ACE wrapper, so keep the provider unchanged and override only the model name.

### 7.3 Initial experimental conditions

For the strict reproduction used here:

- Base prompt: the eight `KEY_INSTRUCTIONS` in `evaluation_react.py`.
- Base tools: `show_app_descriptions`, `show_api_descriptions`, `show_api_doc`, and `search_api_docs`.
- Initial experience: `[]`.

The empty-experience scaffold is:

```text
experiments/playbooks/appworld_empty_playbook.txt
```

It contains section headers but zero experience bullets. `has_playbook()` treats it as empty until at least one `[xxx-00001] ...` experience bullet exists. During initial adaptation, the generator receives no playbook message, while reflector/curator receive `[]`. After the curator adds the first learned experience, the real playbook is used normally.

The default upstream configuration still points to `appworld_initial_playbook.txt`. The empty playbook is selected only through the experiment override below.

### 7.4 Smoke test

Use a separate smoke playbook so the test cannot contaminate the formal run:

```bat
set "ACE_SMOKE_OVERRIDE={"config":{"agent":{"appworld_config":{"timeout_seconds":null},"initial_playbook_file_path":"%REPO%/experiments/playbooks/appworld_empty_playbook.txt","trained_playbook_file_path":"%REPO%/experiments/playbooks/appworld_smoke_playbook.txt","generator_model_config":{"name":"~deepseek/deepseek-v4-flash-latest"},"reflector_model_config":{"name":"~deepseek/deepseek-v4-flash-latest"},"curator_model_config":{"name":"~deepseek/deepseek-v4-flash-latest"},"max_steps":3}}}}"
appworld run ACE_offline_no_GT_adaptation --task-id 82e2fac_1 --override "%ACE_SMOKE_OVERRIDE%"
```

After the smoke test:

```bat
del /q experiments\\playbooks\\appworld_smoke_playbook.txt
rmdir /s /q experiments\\outputs\\ACE_offline_no_GT_adaptation
```

### 7.5 Formal offline adaptation on train

Before the formal run, make sure no old final playbook remains:

```bat
if exist experiments\\playbooks\\appworld_final_playbook.txt (echo WARNING_FINAL_PLAYBOOK_EXISTS) else (echo CLEAN_FINAL_PLAYBOOK)
```

Set the formal override:

```bat
set "ACE_OVERRIDE={"config":{"agent":{"appworld_config":{"timeout_seconds":null},"initial_playbook_file_path":"%REPO%/experiments/playbooks/appworld_empty_playbook.txt","generator_model_config":{"name":"~deepseek/deepseek-v4-flash-latest"},"reflector_model_config":{"name":"~deepseek/deepseek-v4-flash-latest"},"curator_model_config":{"name":"~deepseek/deepseek-v4-flash-latest"}}}}"
```

Run the complete train split:

```bat
appworld run ACE_offline_no_GT_adaptation --override "%ACE_OVERRIDE%"
```

Do not pass `--task-id` for the formal run. Do not override `max_steps`; the experiment config uses the formal value of 40. The current train split contains 90 tasks.

The optimized experience is written to:

```text
experiments/playbooks/appworld_final_playbook.txt
```

Do not delete this file after training; evaluation uses it.

### 7.6 Evaluation on test_normal

Evaluation uses the trained `appworld_final_playbook.txt`; it does not restart from the empty playbook and does not run reflector/curator adaptation.

```bat
set "ACE_EVAL_OVERRIDE={"config":{"agent":{"appworld_config":{"timeout_seconds":null},"generator_model_config":{"name":"~deepseek/deepseek-v4-flash-latest"},"trained_playbook_file_path":"%REPO%/experiments/playbooks/appworld_final_playbook.txt"}}}}"
appworld run ACE_offline_no_GT_evaluation --override "%ACE_EVAL_OVERRIDE%"
appworld evaluate ACE_offline_no_GT_evaluation test_normal
```

Only `test_normal` is required for this reproduction.

### 7.7 Git and generated artifacts

The repository `.gitignore` excludes `experiments/outputs/` and `experiments/playbooks/*`, so generated experiment trajectories and learned playbooks are not added by ordinary `git add` operations.

`appworld_empty_playbook.txt` is a static reproducibility input and should therefore be force-added once:

```bat
git add -f experiments\\playbooks\\appworld_empty_playbook.txt
```

Do not force-add the entire playbooks directory.

### 7.8 Known caveat: cost tracking

The pinned LiteLLM version does not currently have token-cost metadata for `~deepseek/deepseek-v4-flash-latest`. Model calls work, but ACE may report `cost = 0.0`. Therefore `max_cost_per_task` and `max_cost_overall` should not be relied upon as actual spending guards; monitor OpenRouter usage separately.

### 7.9 Local compatibility/reproducibility fixes

This working version includes three small fixes required by the tested setup:

1. `appworld_react_generator_prompt_v2.txt`: stale Jinja variable `supervisor.email` was corrected to `main_user.email`.
2. `evaluation_react.py`: section-only playbooks are treated as empty until a real experience bullet exists.
3. `adaptation_react.py`: reflector and curator see empty initial experience as `[]`, while the internal section scaffold is retained so the curator can add the first learned experience.

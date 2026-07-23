# Instructions
1. Run train-set with `appworld run ACE_offline_no_GT_adaptation`, final playbook will be located in `/experiments/playbooks/appworld_final_playbook.txt` (can configure in `/experiments/configs/ACE_offline_no_GT_adaptation.jsonnet`)

2. Update `ACE_offline_no_GT_evaluation.jsonnet` with final playbook path if necessary (default to `experiment/playbooks/appworld_final_playbook.txt`)

3. Run test-set with `appworld run ACE_offline_no_GT_evaluation`

4. Evaluation test-set scores with: `appworld evaluate ACE_offline_no_GT_evaluation test_normal`
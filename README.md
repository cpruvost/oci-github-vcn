# Github Action CPU and Memory Counter for Oracle Cloud Infrastructure CLI

With Github Action CPU And Memory Counter for Oracle Cloud Infrastructure CLI, you can automate your workflow by executing OCI CLI commands to count OCI resources inside of an Action. Note : This list of regions to count is not used for the moment and is hard coded in the script sh file.  

## Inputs

### `regionscript`

**Required** The region list to count. Ex `"eu-marseille-1"`.
### `mode`

**Required** The mode used to count. OCI CLI or REST. Ex `"ocicli"`. Note : if not ocicli then it is rest by default.

## Outputs

### `cpu`

The number of CPU. Ex : `12`.
### `mem`

The Memory used in GB. Ex : `180`.
### `nbinst`

The number of instances. Ex : `9`.
## Dependencies on other GitHub Actions
- Checkout – To execute the scripts present in your repository
- oci-cli-action - To install Oracle Cloud InfraStructure CLI (OCI CLI)

# Example usage
```yaml
- name: Run OCI Counter Script
        uses: cpruvost/oci-cpu-mem@master
        id: counter
        with:
          regionscript: |
            eu-marseille-1
            eu-frankfurt-1
          mode: rest  
        
- run: |
    echo "CPU : ${{ steps.counter.outputs.cpu }}"  
    echo "MEM : ${{ steps.counter.outputs.mem }}"    
    echo "NBINST : ${{ steps.counter.outputs.nbinst }}"  
```

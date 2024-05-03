###########################################################################################################
# Script Purpose: Automates failover of PPRD and PROD AGs during maintenance
# Author: Landon Fowler
###########################################################################################################


###############
# Paramaeters #
###############

Param(
  [Parameter(Mandatory=$True)]
   [string]$Environment,
	
  [Parameter(Mandatory=$True)]
   [string]$Destination
)

############
# Modules  #
############

Import-Module dbatools

#############
# Funcitons #
#############

################################################################################################################################

function PPRDMove 
{
    
    # Build list of AGs
    $aglist = @(
    "AG1PPRD,50000"
    "AG2PPRD,51000"
    "AG3PPRD,52000"
    )
    

    # Iterate through the list of AGs
    foreach ($ag in $agList)
    {
        
        # Split out AG name
        $agName = ($ag.Split(","))[0]
        

        # Determine the replica information
        $replicas = Get-DbaAgReplica -SqlInstance $ag
        # From the replica info, get just the server name of the primary.
        $primary = ($replicas | where {$_.Role -eq "Primary"} | select -ExpandProperty name).Split("\")[0]
        # From the replica info, get the instance name (server\instance).
        $secondary = $replicas | where {$_.Role -eq "Secondary"} | select -ExpandProperty name
        
        # Actions to take if AGs are being failed over to the A nodes.
        if ($Destination.ToUpper() -eq "A")
        {

            # If the primary replica is one of the B nodes, fail over to A. Otherwise do nothing.
            if (($primary -eq "SERVER2PPRD") -or ($primary -eq "SERVER4PPRD"))
            {
               $message = "Moving " + $agName + " to " + $secondary
               Write-Host $message -ForegroundColor Green
               Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
            }

            else
            {
                $message = $agName + " is already on the A node."
                Write-Host $message -ForegroundColor Green
            }


        }

        # Actions to take if AGs are being failed over to the B nodes.
        elseif ($Destination.ToUpper() -eq "B")
        {

            # If the primary replica is one of the A nodes, fail over to B. Otherwise do nothing.
            if (($primary -eq "SERVER1PPRD") -or ($primary -eq "SERVER3PPRD"))
            {
               $message = "Moving " + $agName + " to " + $secondary
               Write-Host $message -ForegroundColor Green
               Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
            }

            else
            {
                $message = $agName + " is already on the B node."
                Write-Host $message -ForegroundColor Green
            }
        }

        # Actions to take if returning to Home nodes.
        elseif ($Destination.ToUpper() -eq "HOME")
        {
            
            
            # AG1PPRD
            if ($agName -eq "AG1PPRD")
            {
                
                if ($primary -eq "SERVER2PPRD")
                {
                    $message = "Moving " + $agName + " to " + $secondary
                    Write-Host $message -ForegroundColor Green
                    Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                }
                
           
            }


            # AG2PPRD
            elseif ($agName -eq "AG2PPRD")
            {

                if ($primary -eq "SERVER3PPRD")
                {
                    $message = "Moving " + $agName + " to " + $secondary
                    Write-Host $message -ForegroundColor Green
                    Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                }
           
            }

            # AG3PPRD
            elseif ($agName -eq "AG3PPRD")
            {
                if ($primary -eq "SERVER1PPRD")
                {
                    $message = "Moving " + $agName + " to " + $secondary
                    Write-Host $message -ForegroundColor Green
                    Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                }
           
            }

            # Give a message if none of the AG names in the list match.
            else
            {
                Write-Host "AG name not found." -ForegroundColor Yellow
            }
        }

        # Give a message if something other than A or B was specified for the destination.
        else
        {
            Write-Host 'Invalid destination specified. Please use "A" or "B".' -ForegroundColor Yellow
        }
        
    }
    
    
}

################################################################################################################################


function PRODMove
{
        # Build list of AGs
        
        $aglist = @(
            "AG1PROD,50000"
            "AG2PROD,51000"
            "AG3PROD,52000"
            )
            
        
            # Iterate through the list of AGs
            foreach ($ag in $agList)
            {
                
                # Split out AG name
                $agName = ($ag.Split(","))[0]
                
        
                # Determine the replica information
                $replicas = Get-DbaAgReplica -SqlInstance $ag
                # From the replica info, get just the server name of the primary.
                $primary = ($replicas | where {$_.Role -eq "Primary"} | select -ExpandProperty name).Split("\")[0]
                # From the replica info, get the instance name (server\instance).
                $secondary = $replicas | where {$_.Role -eq "Secondary"} | select -ExpandProperty name

                
                # Actions to take if AGs are being failed over to the A nodes.
                if ($Destination.ToUpper() -eq "A")
                {
                    # If the primary replica is one of the B nodes, fail over to A. Otherwise do nothing.
                    if ($primary.substring($primary.length -1) -eq "B")
                    {
                       $message = "Moving " + $agName + " to " + $secondary
                       Write-Host $message -ForegroundColor Green
                       Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                    }
        
                    else
                    {
                        $message = $agName + " is already on the A node."
                        Write-Host $message -ForegroundColor Green
                    }
        
                }
        
                # Actions to take if AGs are being failed over to the B nodes.
                elseif ($Destination.ToUpper() -eq "B")
                {

                    # If the primary replica is one of the A nodes, fail over to B. Otherwise do nothing.
                    if ($primary.substring($primary.length -1) -eq "A")
                    {
                       $message = "Moving " + $agName + " to " + $secondary
                       Write-Host $message -ForegroundColor Green
                       Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                    }
        
                    else
                    {
                        $message = $agName + " is already on the B node."
                        Write-Host $message -ForegroundColor Green
                    }
                }
        
                # Actions to take if returning to Home nodes.
                elseif ($Destination.ToUpper() -eq "HOME")
                {
                    
                    
                    # AG1PROD
                    if ($agName -eq "AG1PROD")
                    {
                        
                        if ($primary -eq "AG2PROD")
                        {
                            $message = "Moving " + $agName + " to " + $secondary
                            Write-Host $message -ForegroundColor Green
                            Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                        }
                        
                   
                    }
        
        
                    # AG2PROD
                    elseif ($agName -eq "AG2PROD")
                    {
        
                        if ($primary -eq "AG1PROD")
                        {
                            $message = "Moving " + $agName + " to " + $secondary
                            Write-Host $message -ForegroundColor Green
                            Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                        }
                   
                    }
        
                    # AG3PROD
                    elseif ($agName -eq "AG3PROD")
                    {
                        if ($primary -eq "AG2PROD")
                        {
                            $message = "Moving " + $agName + " to " + $secondary
                            Write-Host $message -ForegroundColor Green
                            Invoke-DbaAgFailover -SqlInstance $secondary -AvailabilityGroup $agName -EnableException -Confirm:$false
                        }
                   
                    }
        
                    
                    # Give a message if none of the AG names in the list match.
                    else
                    {
                        Write-Host "AG name not found." -ForegroundColor Yellow
                    }
                    
                }
                
                # Give a message if something other than A or B was specified for the destination.
                else
                {
                    Write-Host 'Invalid destination specified. Please use "A" or "B".' -ForegroundColor Yellow
                }
                
            }
            
            
}
        


################################################################################################################################


########
# Body #
########

# If working with PPRD, call its function.
if ($Environment -eq "PPRD")
{
    PPRDMove
}

# If working with PROD, call its function.
elseif ($Environment -eq "PROD")
{
    # Give an extra warning when working in PROD and prompt for whether to continue.
    Write-Host "WARNING: You are about to take action on PRODUCTION systems. Are you sure you want to continue? (Y or N)" -ForegroundColor DarkYellow
    $prompt = Read-Host

    if ($prompt -eq "Y")
    {
        PRODMove
    }

    else 
    {
        Write-Host "Carefully edging back to safety..." -ForegroundColor Green    
    }
    
    
}

# Exit if no environment is specified
else
{
    Write-Host 'Invalid environment specified. Please use "PPRD" or "PROD".' -ForegroundColor Yellow
}